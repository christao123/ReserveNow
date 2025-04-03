<template>
  <AppNavbar />
  <div class="reservations-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">My Reservations</h1>
        <p class="page-subtitle">Manage your restaurant booking records</p>
      </div>
    </div>

    <!-- 内容区域 -->
    <div class="page-content">
      <!-- 状态筛选 -->
      <div class="filter-section">
        <div class="filter-tags">
          <el-tag
            v-for="status in statusOptions"
            :key="status.value"
            :class="['status-tag', { active: selectedStatus.includes(status.value) }]"
            @click="toggleStatus(status.value)"
          >
            {{ status.label }}
            <span class="tag-count" v-if="getStatusCount(status.value)">
              {{ getStatusCount(status.value) }}
            </span>
          </el-tag>
        </div>
      </div>

      <!-- 加载中状态 -->
      <div v-if="loading" class="loading-container">
        <div class="loading-spinner"></div>
        <p>Loading reservation records...</p>
      </div>

      <!-- 无预订状态 -->
      <div v-else-if="reservations.length === 0" class="empty-state">
        <div class="empty-illustration">
          <el-icon><Calendar /></el-icon>
        </div>
        <h2>No Reservation Records</h2>
        <p>You haven't made any restaurant reservations yet. Start exploring delicious food now!</p>
        <el-button type="primary" class="explore-button" @click="goToExplore">
          Browse Restaurants
          <el-icon class="el-icon--right"><ArrowRight /></el-icon>
        </el-button>
      </div>

      <!-- 预订列表 -->
      <div v-else class="reservations-list">
        <div 
          v-for="reservation in reservations" 
          :key="reservation.id" 
          class="reservation-card"
          :class="getStatusClass(reservation.status)"
        >
          <div class="card-header">
            <div class="restaurant-info">
              <img :src="reservation.restaurantPhoto" :alt="reservation.restaurantName" class="restaurant-photo">
              <div class="info-content">
                <h3>{{ reservation.restaurantName }}</h3>
                <p class="address">
                  <el-icon><Location /></el-icon>
                  Table Type: {{ reservation.address }}
                </p>
              </div>
            </div>
            <div class="status-badge" :class="getStatusClass(reservation.status)">
              {{ reservation.statusText }}
            </div>
          </div>

          <div class="card-content">
            <div class="reservation-details">
              <div class="detail-item">
                <el-icon><Calendar /></el-icon>
                <span>Reservation Date: {{ formatDate(reservation.reservationDate) }}</span>
              </div>
              <div class="detail-item">
                <el-icon><Clock /></el-icon>
                <span>Reservation Time: {{ reservation.reservationTime }}</span>
              </div>
              <div class="detail-item">
                <el-icon><User /></el-icon>
                <span>Number of Guests: {{ reservation.numberOfGuests }}</span>
              </div>
              <div class="detail-item" v-if="reservation.specialRequests">
                <el-icon><Message /></el-icon>
                <span>Special Requests: {{ reservation.specialRequests }}</span>
              </div>
              <div class="detail-item reservation-code">
                <el-icon><Ticket /></el-icon>
                <span>Reservation Code: {{ reservation.reservationCode }}</span>
              </div>
            </div>

            <div class="card-actions">
              <el-button 
                v-if="reservation.status === 1 || reservation.status === 2"
                type="danger" 
                plain
                @click="showCancelDialog(reservation)"
              >
                Cancel Reservation
              </el-button>
              <el-button 
                v-if="reservation.status === 2"
                type="primary"
                @click="viewQRCode(reservation)"
              >
                View QR Code
              </el-button>
            </div>
          </div>
        </div>

        <!-- 分页 -->
        <div class="pagination-container" v-if="total > pageSize">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="pageSize"
            :total="total"
            layout="prev, pager, next"
            @current-change="handlePageChange"
          />
        </div>
      </div>
    </div>
  </div>

  <!-- 取消预订对话框 -->
  <el-dialog
    v-model="cancelDialogVisible"
    title="Cancel Reservation"
    width="30%"
    class="cancel-dialog"
  >
    <div class="cancel-content">
      <p class="cancel-warning">
        <el-icon class="warning-icon"><Warning /></el-icon>
        Are you sure you want to cancel this reservation? This action cannot be undone.
      </p>
      <el-form :model="cancelForm" label-position="top">
        <el-form-item label="Cancellation Reason">
          <el-input
            v-model="cancelForm.reason"
            type="textarea"
            rows="3"
            placeholder="Please briefly explain the reason for cancellation (optional)"
          />
        </el-form-item>
      </el-form>
    </div>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="cancelDialogVisible = false">Back</el-button>
        <el-button type="danger" @click="confirmCancel" :loading="cancelling">
          Confirm Cancel
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- 预订码对话框 -->
  <el-dialog
    v-model="qrCodeDialogVisible"
    title="Reservation QR Code"
    width="30%"
    class="qrcode-dialog"
  >
    <div class="qrcode-content">
      <div class="qrcode-container">
        <!-- 这里可以使用实际的二维码组件 -->
        <div class="qrcode-placeholder">
          Reservation Code: {{ selectedReservation?.reservationCode }}
        </div>
      </div>
      <p class="qrcode-tip">Please show this QR code when you arrive at the restaurant</p>
    </div>
  </el-dialog>

  <AppFooter />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import AppNavbar from '@/components/AppNavbar.vue';
import AppFooter from '@/components/AppFooter.vue';
import request from '@/utils/request';
import { 
  Calendar,
  Clock,
  Location,
  User,
  Message,
  Warning,
  ArrowRight,
  Ticket
} from '@element-plus/icons-vue';

const router = useRouter();
const loading = ref(false);
const reservations = ref([]);
const total = ref(0);
const currentPage = ref(1);
const pageSize = ref(10);
const selectedStatus = ref(['1', '2']); 
const cancelDialogVisible = ref(false);
const qrCodeDialogVisible = ref(false);
const selectedReservation = ref(null);
const cancelling = ref(false);
const cancelForm = ref({
  reason: ''
});

// 状态选项
const statusOptions = [
  { label: 'Pending', value: '1' },
  { label: 'Confirmed', value: '2' },
  { label: 'Completed', value: '3' },
  { label: 'Cancelled', value: '0' },
  { label: 'Rejected', value: '4' }
];

// 获取预订列表
const fetchReservations = async () => {
  loading.value = true;
  try {
    const response = await request.get('/reservations', {
      params: {
        page: currentPage.value,
        pageSize: pageSize.value,
        status: selectedStatus.value.join(',')
      }
    });
    
    if (response.code === 200) {
      // 处理数据格式
      reservations.value = response.data.list.map(item => ({
        id: item.id,
        restaurantId: item.restaurantId,
        restaurantName: item.restaurantName,
        restaurantPhoto: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=2070&auto=format&fit=crop', // 默认图片
        address: item.tableType, 
        reservationDate: new Date(item.reservationTime),
        reservationTime: new Date(item.reservationTime).toLocaleTimeString('zh-CN', {
          hour: '2-digit',
          minute: '2-digit'
        }),
        numberOfGuests: item.personCount,
        specialRequests: item.remarks,
        status: item.statusValue,
        statusText: item.statusText,
        reservationCode: `RES${String(item.id).padStart(6, '0')}`, // 生成预订码
        cancelReason: item.cancelReason
      }));
      total.value = response.data.total;
    }
  } catch (error) {
    ElMessage.error('Failed to load reservation records');
  } finally {
    loading.value = false;
  }
};

// 切换状态筛选
const toggleStatus = (status) => {
  const index = selectedStatus.value.indexOf(status);
  if (index > -1) {
    selectedStatus.value.splice(index, 1);
  } else {
    selectedStatus.value.push(status);
  }
  currentPage.value = 1;
  fetchReservations();
};

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    1: 'Pending',
    2: 'Confirmed',
    3: 'Completed',
    0: 'Cancelled',
    4: 'Rejected'
  };
  return statusMap[status] || 'Unknown Status';
};

// 获取状态类名
const getStatusClass = (status) => {
  const statusMap = {
    0: 'cancelled',
    1: 'pending',
    2: 'confirmed',
    3: 'completed',
    4: 'rejected'
  };
  return statusMap[status] || '';
};

// 获取各状态数量
const getStatusCount = (status) => {
  return reservations.value.filter(r => r.status === parseInt(status)).length;
};

// 格式化日期
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  });
};

// 显示取消对话框
const showCancelDialog = (reservation) => {
  selectedReservation.value = reservation;
  cancelDialogVisible.value = true;
};

// 确认取消预订
const confirmCancel = async () => {
  if (!selectedReservation.value) return;
  
  cancelling.value = true;
  try {
    const response = await request.put(
      `/reservations/${selectedReservation.value.id}/cancel`,
      { reason: cancelForm.value.reason }
    );
    
    if (response.code === 200) {
      ElMessage.success('Reservation cancelled successfully');
      cancelDialogVisible.value = false;
      fetchReservations();
    }
  } catch (error) {
    ElMessage.error('Failed to cancel reservation');
  } finally {
    cancelling.value = false;
  }
};

// 查看预订码
const viewQRCode = (reservation) => {
  selectedReservation.value = reservation;
  qrCodeDialogVisible.value = true;
};

// 前往探索页面
const goToExplore = () => {
  router.push('/explore');
};

// 处理分页变化
const handlePageChange = (page) => {
  currentPage.value = page;
  fetchReservations();
};

// 组件挂载时获取预订列表
onMounted(() => {
  fetchReservations();
});
</script>

<style lang="scss" scoped>
// 变量
$primary-color: #ff4757;
$secondary-color: #f8f1ff;
$accent-color: #6c5ce7;
$dark-color: #2d3436;
$light-color: #f9f9f9;
$gray-color: #636e72;

// 状态颜色
$status-pending: #f39c12;
$status-confirmed: #2ecc71;
$status-completed: #3498db;
$status-cancelled: #95a5a6;
$status-rejected: #e74c3c;

// 页面基础样式
.reservations-page {
  padding-top: 70px;
  min-height: 100vh;
  background-color: #fcfcfc;
}

// 页面头部
.page-header {
  background: linear-gradient(135deg, $secondary-color, #fff);
  padding: 60px 20px;
  text-align: center;
  margin-bottom: 40px;

  .page-title {
    font-size: 36px;
    font-weight: 800;
    margin: 0 0 10px;
    background: linear-gradient(135deg, $dark-color, $primary-color);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .page-subtitle {
    font-size: 16px;
    color: $gray-color;
    margin: 0;
  }

}

// 页面内容
.page-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px 50px;
}

// 状态筛选
.filter-section {
  margin-bottom: 30px;

  .filter-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;

    .status-tag {
      cursor: pointer;
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      transition: all 0.3s ease;
      user-select: none;
      
      &.active {
        background-color: $primary-color;
        color: white;
        border-color: $primary-color;
      }

      .tag-count {
        margin-left: 5px;
        font-size: 12px;
        opacity: 0.8;
      }
    }
  }
}

// 预订卡片
.reservation-card {
  background: white;
  border-radius: 16px;
  margin-bottom: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.1);
  }

  .card-header {
    padding: 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(0, 0, 0, 0.05);

    .restaurant-info {
      display: flex;
      align-items: center;
      gap: 15px;

      .restaurant-photo {
        width: 60px;
        height: 60px;
        border-radius: 8px;
        object-fit: cover;
      }

      .info-content {
        h3 {
          margin: 0 0 5px;
          font-size: 18px;
          color: $dark-color;
        }

        .address {
          margin: 0;
          font-size: 14px;
          color: $gray-color;
          display: flex;
          align-items: center;
          gap: 5px;
        }
      }
    }

    .status-badge {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 500;

      &.pending {
        background-color: rgba($status-pending, 0.1);
        color: $status-pending;
      }

      &.confirmed {
        background-color: rgba($status-confirmed, 0.1);
        color: $status-confirmed;
      }

      &.completed {
        background-color: rgba($status-completed, 0.1);
        color: $status-completed;
      }

      &.cancelled {
        background-color: rgba($status-cancelled, 0.1);
        color: $status-cancelled;
      }

      &.rejected {
        background-color: rgba($status-rejected, 0.1);
        color: $status-rejected;
      }
    }
  }

  .card-content {
    padding: 20px;

    .reservation-details {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 20px;

      .detail-item {
        display: flex;
        align-items: center;
        gap: 8px;
        color: $gray-color;
        font-size: 14px;

        .el-icon {
          color: $primary-color;
        }
      }

      .reservation-code {
        grid-column: 1 / -1;
        background: rgba($primary-color, 0.05);
        padding: 10px;
        border-radius: 8px;
        margin-top: 10px;
        
        .el-icon {
          color: $primary-color;
        }
      }
    }

    .card-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
    }
  }
}

// 加载中状态
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;

  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 3px solid rgba($primary-color, 0.1);
    border-radius: 50%;
    border-top-color: $primary-color;
    animation: spin 1s linear infinite;
    margin-bottom: 20px;
  }

  p {
    color: $gray-color;
    font-size: 14px;
  }
}

// 空状态
.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);

  .empty-illustration {
    font-size: 60px;
    color: $primary-color;
    margin-bottom: 20px;
    opacity: 0.5;
  }

  h2 {
    font-size: 24px;
    color: $dark-color;
    margin: 0 0 10px;
  }

  p {
    color: $gray-color;
    margin: 0 0 30px;
  }

  .explore-button {
    padding: 12px 30px;
  }
}

// 取消对话框
.cancel-dialog {
  .cancel-warning {
    display: flex;
    align-items: center;
    gap: 10px;
    color: $status-rejected;
    margin-bottom: 20px;

    .warning-icon {
      font-size: 20px;
    }
  }
}

// 预订码对话框
.qrcode-dialog {
  .qrcode-content {
    text-align: center;

    .qrcode-container {
      margin-bottom: 20px;
    }

    .qrcode-tip {
      color: $gray-color;
      font-size: 14px;
      margin: 0;
    }
  }
}

// 动画
@keyframes spin {
  to { transform: rotate(360deg); }
}

// 响应式样式
@media (max-width: 768px) {
  .page-header {
    padding: 40px 20px;

    .page-title {
      font-size: 28px;
    }
  }

  .reservation-card {
    .card-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 15px;

      .status-badge {
        align-self: flex-start;
      }
    }

    .card-content {
      .reservation-details {
        grid-template-columns: 1fr;
      }
    }
  }
}
</style> 