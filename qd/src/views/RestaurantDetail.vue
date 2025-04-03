<template>
    <div class="restaurant-detail-container">
      <!-- 顶部导航栏 -->
      <header class="detail-header">
        <div class="header-actions">
          <el-button class="back-button" @click="goBack" circle>
            <el-icon><ArrowLeft /></el-icon>
          </el-button>
          <div class="actions-right">
            <el-button class="favorite-button" @click="toggleFavorite" circle :class="{ 'is-favorite': restaurant.isFavorite }">
              <el-icon><Star /></el-icon>
            </el-button>
            <el-button class="share-button" circle>
              <el-icon><Share /></el-icon>
            </el-button>
          </div>
        </div>
      </header>
  
      <!-- 餐厅照片画廊 -->
      <div class="restaurant-gallery" v-loading="loading">
        <el-carousel v-if="restaurant.photos && restaurant.photos.length" height="450px" indicator-position="outside" arrow="always" :autoplay="true" :interval="5000">
          <el-carousel-item v-for="(photo, index) in restaurant.photos" :key="index">
            <div class="gallery-item" :style="{ backgroundImage: `url(${photo})` }"></div>
          </el-carousel-item>
        </el-carousel>
        <div v-else class="no-photos">
          <el-icon><Picture /></el-icon>
          <p>No restaurant photos available</p>
        </div>
        
        <!-- 餐厅标题覆盖层 -->
        <div class="restaurant-title-overlay">
          <h1>{{ restaurant.name || '加载中...' }}</h1>
          <div class="quick-info">
            <div class="info-item cuisine">
              <el-icon><Food /></el-icon>
              <span>{{ restaurant.cuisine || '综合菜系' }}</span>
            </div>
            <div class="rating-display">
              <span class="rating-value">{{ restaurant.rating || '-' }}</span>
              <el-rate v-model="restaurant.rating" disabled text-color="#ffcc00" />
              <span class="review-count">({{ restaurant.reviewCount || 0 }})</span>
            </div>
            <div class="info-item">
              <el-icon><Location /></el-icon>
              <span>{{ restaurant.address ? restaurant.address.substring(0, 15) + '...' : '暂无地址' }}</span>
            </div>
          </div>
        </div>
      </div>
  
      <!-- 餐厅基本信息 -->
      <div class="restaurant-info-card" v-loading="loading">
        <div class="info-section">
          <div class="info-row">
            <el-icon><Location /></el-icon>
            <span>{{ restaurant.address || '暂无地址信息' }}</span>
          </div>
          <div class="info-row">
            <el-icon><Phone /></el-icon>
            <span>{{ restaurant.phone || '暂无联系电话' }}</span>
          </div>
          <div class="info-row">
            <el-icon><Clock /></el-icon>
            <span>{{ formatBusinessHours(restaurant.businessHours) }}</span>
          </div>
        </div>
  
        <div class="description-section">
          <h3>Restaurant Introduction</h3>
          <p>{{ restaurant.description || 'No restaurant description available' }}</p>
        </div>
      </div>
  
      <!-- 桌位信息 -->
      <div class="tables-section" v-loading="loading">
        <div class="section-header">
          <h2>Available Tables</h2>
          <el-button type="primary" class="reserve-button" @click="startReservation">Book Now</el-button>
        </div>
  
        <div class="tables-container">
          <el-card v-for="table in restaurant.tables" :key="table.id" class="table-card" 
                   :class="{'vip-table': table.type.includes('VIP'), 'standard-table': table.type.includes('标准'), 'large-table': table.type.includes('大桌'), 'table-available': true}"
                   @click="selectTable(table)">
            <div class="table-status">
              <span class="status-badge available">Available</span>
            </div>
            <div v-if="table.type.includes('VIP')" class="vip-ribbon">VIP</div>
            <div v-if="table.type.includes('大桌')" class="large-ribbon">大桌</div>
            <div class="table-header">
              <div class="table-icon-container">
                <el-icon v-if="table.type.includes('VIP')" class="table-icon vip"><TrophyBase /></el-icon>
                <el-icon v-else-if="table.type.includes('大桌')" class="table-icon large"><SetUp /></el-icon>
                <el-icon v-else class="table-icon standard"><Menu /></el-icon>
              </div>
              <div class="table-type-tag">
                {{ table.type }}
              </div>
            </div>
            <div class="table-body">
              <div class="table-features">
                <div class="feature" v-if="table.type.includes('VIP')">
                  <span>Premium Booking</span>
                </div>
                <div class="feature" v-if="table.type.includes('VIP')">
                  <span>Private Setting</span>
                </div>
                <div class="feature" v-if="table.type.includes('大桌')">
                  <span>Group Dining</span>
                </div>
                <div class="feature" v-if="table.type.includes('标准')">
                  <span>Comfortable Environment</span>
                </div>
                <div class="feature" v-if="!table.type.includes('VIP') && !table.type.includes('大桌') && !table.type.includes('标准')">
                  <span>Regular Seating</span>
                </div>
              </div>
              <div class="table-info">
                <div class="table-capacity">
                  <el-icon><User /></el-icon>
                  <span>{{ table.capacity }} Person Table</span>
                </div>
                <div class="table-availability">
                  <el-icon><Timer /></el-icon>
                  <span>Available All Day</span>
                </div>
              </div>
            </div>
            <div class="table-actions">
              <el-button type="primary" :plain="!table.type.includes('VIP')">Select This Table</el-button>
            </div>
          </el-card>
  
          <div v-if="!restaurant.tables || restaurant.tables.length === 0" class="no-tables">
            <el-empty description="No tables available for booking"></el-empty>
          </div>
        </div>
      </div>
  
      <!-- 时间选择对话框 -->
      <el-dialog
        v-model="timeSelectionVisible"
        title="Select Booking Time"
        width="660px"
        destroy-on-close
        :close-on-click-modal="false"
        class="time-selection-dialog"
        :show-close="true"
      >
        <div v-if="selectedTable" class="time-selection-content">
          <div class="selected-table-info">
            <div class="table-icon-wrapper">
              <div class="table-icon" :class="{'vip-icon': selectedTable.type.includes('VIP'), 'large-icon': selectedTable.type.includes('大桌'), 'standard-icon': selectedTable.type.includes('标准')}">
                <el-icon v-if="selectedTable.type.includes('VIP')"><TrophyBase /></el-icon>
                <el-icon v-else-if="selectedTable.type.includes('大桌')"><SetUp /></el-icon>
                <el-icon v-else><Menu /></el-icon>
              </div>
            </div>
            <div class="table-details">
              <h3>{{ selectedTable.type }}</h3>
              <p><el-icon><User /></el-icon> {{ selectedTable.capacity }} Person Table</p>
              <div class="table-tags">
                <span v-if="selectedTable.type.includes('VIP')" class="tag vip-tag">Premium Booking</span>
                <span v-if="selectedTable.type.includes('VIP')" class="tag vip-tag">Private Setting</span>
                <span v-if="selectedTable.type.includes('大桌')" class="tag large-tag">Group Dining</span>
                <span v-if="selectedTable.type.includes('标准')" class="tag standard-tag">Comfortable Environment</span>
                <span v-if="!selectedTable.type.includes('VIP') && !selectedTable.type.includes('大桌') && !selectedTable.type.includes('标准')" class="tag standard-tag">Regular Seating</span>
              </div>
            </div>
          </div>
          
          <div class="selection-container">
            <div class="date-selection">
              <h4><el-icon><Calendar /></el-icon> Select Date</h4>
              <el-date-picker
                v-model="selectedDate"
                type="date"
                placeholder="Select Date"
                format="YYYY-MM-DD"
                :disabled-date="disabledDate"
                :default-value="selectedDate"
                @change="handleDateChange"
              />
              <p class="note"><el-icon><InfoFilled /></el-icon> Bookings can only be made for tomorrow and later dates</p>
            </div>
            
            <div class="time-slots" v-loading="loadingTimeSlots">
              <h4>
                <el-icon><Timer /></el-icon> Select Time
                <span v-if="selectedTimeRange" class="selected-time-range">
                  <el-icon><Check /></el-icon> {{ selectedTimeRange }}
                </span>
              </h4>
              <p class="time-hint"><el-icon><Clock /></el-icon> Business Hours: {{ formatBusinessHours(restaurant.businessHours) }}</p>
              <p class="day-type-hint"><el-icon><Calendar /></el-icon> Current Selection: {{ formatSelectedDay(selectedDate) }}</p>
              <p class="selection-hint"><el-icon><Warning /></el-icon> Note: You can select multiple consecutive time slots</p>
              
              <div class="time-grid">
                <el-button 
                  v-for="time in availableTimeSlots" 
                  :key="time.value"
                  :disabled="time.disabled"
                  :class="{ 'selected': selectedTimeSlots.some(slot => slot.value === time.value) }"
                  @click="handleTimeSelection(time)"
                  size="large"
                >
                  {{ time.label }}
                </el-button>
              </div>
            </div>
          </div>
          
          <div class="reservation-details">
            <h4><el-icon><Memo /></el-icon> Booking Details</h4>
            
            <div class="details-grid">
              <div class="detail-item">
                <label for="person-count">Number of Guests</label>
                <el-input-number 
                  id="person-count"
                  v-model="personCount"
                  :min="1" 
                  :max="selectedTable.capacity || 20"
                  size="large"
                  :step="1"
                  step-strictly
                />
                <span class="capacity-info">Maximum capacity: {{ selectedTable.capacity }} people</span>
              </div>
              
              <div class="detail-item remarks-item">
                <label for="remarks">Special Requests</label>
                <el-input
                  id="remarks"
                  v-model="reservationRemarks"
                  type="textarea"
                  placeholder="Enter special requests, e.g.: window seat, high chair needed, etc."
                  :rows="3"
                  maxlength="200"
                  show-word-limit
                />
              </div>
            </div>
          </div>
        </div>
        
        <template #footer>
          <div class="dialog-footer">
            <div class="reservation-summary" v-if="selectedTimeSlots.length > 0">
              <div class="summary-item">
                <span class="label">Booking Date:</span>
                <span class="value">{{ selectedDate.toLocaleDateString() }}</span>
              </div>
              <div class="summary-item">
                <span class="label">Booking Time:</span>
                <span class="value">{{ selectedTimeRange }}</span>
              </div>
              <div class="summary-item">
                <span class="label">Number of Guests:</span>
                <span class="value">{{ personCount }} people</span>
              </div>
            </div>
          
            <div class="action-buttons">
              <el-button @click="timeSelectionVisible = false" class="cancel-btn">Cancel</el-button>
              <el-button 
                type="primary" 
                :disabled="selectedTimeSlots.length === 0" 
                @click="confirmReservation"
                class="confirm-btn"
              >
                Confirm Booking
              </el-button>
            </div>
          </div>
        </template>
      </el-dialog>
  
      <!-- 餐厅地图位置 -->
      <div class="map-section">
        <h2>Location</h2>
        <div class="map-container">
          <div class="google-map-container">
            <iframe 
              v-if="restaurant.latitude && restaurant.longitude"
              :src="`https://www.google.com/maps/embed/v1/place?key=YOUR_GOOGLE_MAPS_API_KEY&q=${restaurant.latitude},${restaurant.longitude}&zoom=15`"
              width="100%" 
              height="300" 
              style="border:0;" 
              allowfullscreen="" 
              loading="lazy" 
              referrerpolicy="no-referrer-when-downgrade">
            </iframe>
            <div v-else class="map-placeholder">
              <el-icon><MapLocation /></el-icon>
              <p>Loading map...</p>
            </div>
          </div>
          <div class="address-detail">
            <p><el-icon><Location /></el-icon> {{ restaurant.address }}</p>
            <el-button type="primary" plain @click="openGoogleMapsNavigation">
              Navigate Here
            </el-button>
          </div>
        </div>
      </div>
  
      <!-- 餐厅评论区 -->
      <div class="reviews-section">
        <div class="section-header">
          <h2>Customer Reviews ({{ reviewsTotal || 0 }})</h2>
        </div>

        <div class="rating-filter">
          <span class="filter-label">Filter by Rating:</span>
          <div class="rating-buttons">
            <el-button 
              size="small" 
              :type="reviewsRating === null ? 'primary' : 'default'"
              :class="{'active-rating': reviewsRating === null}"
              @click="filterReviewsByRating(null)"
            >
              All
            </el-button>
          </div>
        </div>
  
        <div class="reviews-container" v-loading="reviewsLoading">
          <div v-if="reviewsList.length > 0" class="reviews-list">
            <div v-for="review in reviewsList" :key="review.id" class="review-item">
              <div class="review-header">
                <div class="user-info">
                  <el-avatar :src="review.userAvatar" :size="48">
                    {{ review.userName ? review.userName.charAt(0) : 'User' }}
                  </el-avatar>
                  <div class="user-details">
                    <div class="user-name">{{ review.userName || 'Anonymous User' }}</div>
                    <div class="review-time">{{ formatReviewTime(review.createdAt) }}</div>
                  </div>
                </div>
                <div class="review-rating">
                  <span class="rating-value">{{ review.rating }}</span>
                  <el-rate v-model="review.rating" disabled text-color="#ffcc00" />
                </div>
              </div>
              
              <div class="review-content">
                <p>{{ review.content }}</p>
                
                <div v-if="(review.photos && review.photos.length) || (review.videos && review.videos.length)" class="review-media">
                  <el-image 
                    v-for="(photo, index) in review.photos" 
                    :key="`photo-${index}`"
                    :src="photo" 
                    :preview-src-list="review.photos"
                    :initial-index="index"
                    fit="cover"
                    class="review-media-item"
                    :preview-teleported="true"
                  >
                    <template #error>
                      <div class="image-error">
                        <el-icon><Picture /></el-icon>
                        <span>Failed to load</span>
                      </div>
                    </template>
                  </el-image>
                  
                  <div 
                    v-for="(video, index) in review.videos" 
                    :key="`video-${index}`"
                    class="review-media-item video-container"
                    @click.stop="playVideo($event)"
                  >
                    <video 
                      :src="video" 
                      controls
                      class="review-video"
                      preload="metadata"
                      @click.stop
                    />
                  </div>
                </div>
              </div>
            </div>
            
            <div v-if="reviewsList.length < reviewsTotal" class="load-more">
              <el-button type="primary" plain @click="loadMoreReviews" :loading="reviewsLoading">
                加载更多
              </el-button>
            </div>
          </div>
          
          <div v-else-if="!reviewsLoading" class="no-reviews">
            <el-empty description="No reviews yet. Be the first to write a review!"></el-empty>
          </div>
        </div>
      </div>
  
      <!-- 底部操作区 -->
      <div class="bottom-action-bar">
        <el-button type="primary" class="reserve-action-btn" @click="startReservation">
          <el-icon><Calendar /></el-icon> Book Now
        </el-button>
      </div>
  
      <!-- Footer -->
      <AppFooter />
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, computed, watch } from 'vue';
  import { useRouter, useRoute } from 'vue-router';
  import { ElMessage } from 'element-plus';
  import { 
    ArrowLeft, Star, Share, Location, Phone, Clock, Calendar,
    DeskLamp, User, TrophyBase, MapLocation, Picture, Food, Timer, SetUp,
    InfoFilled, Check, Warning, Memo, Menu, VideoPlay
  } from '@element-plus/icons-vue';
  import request from '@/utils/request';
  import AppFooter from '@/components/AppFooter.vue';
  
  const router = useRouter();
  const route = useRoute();
  const restaurantId = route.params.id;
  
  // 餐厅数据
  const restaurant = ref({
    photos: [],
    tables: []
  });
  const loading = ref(true);
  
  // 评价相关数据
  const reviewsLoading = ref(false);
  const reviewsList = ref([]);
  const reviewsTotal = ref(0);
  const reviewsPage = ref(1);
  const reviewsPageSize = ref(5);
  const reviewsRating = ref(null);
  
  // 获取用户信息
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'));
  const isUserLoggedIn = computed(() => {
    return !!userInfo.value && !!userInfo.value.token;
  });
  
  // 获取餐厅详情
  const fetchRestaurantDetail = async () => {
    loading.value = true;
    try {
      const headers = {};
      if (isUserLoggedIn.value) {
        headers.Authorization = `Bearer ${userInfo.value.token}`;
      }
  
      const res = await request({
        url: `/restaurants/${restaurantId}`,
        method: 'GET',
        headers
      });
      
      restaurant.value = res.data;
      
      // 确保photos是数组
      if (!restaurant.value.photos) {
        restaurant.value.photos = [];
      }
      
      // 确保tables是数组
      if (!restaurant.value.tables) {
        restaurant.value.tables = [];
      }
      
      // 确保经纬度是数值类型
      if (restaurant.value.latitude && restaurant.value.longitude) {
        restaurant.value.latitude = parseFloat(restaurant.value.latitude);
        restaurant.value.longitude = parseFloat(restaurant.value.longitude);
      }
    } catch (error) {
      console.error('获取餐厅详情失败', error);
      ElMessage.error('获取餐厅信息失败，请稍后重试');
    } finally {
      loading.value = false;
    }
  };
  
  // 返回上一页
  const goBack = () => {
    router.push('/');
  };
  
  const toggleFavorite = async () => {
    if (!isUserLoggedIn.value) {
      ElMessage.warning('Please login first to bookmark the restaurant');
      router.push('/login');
      return;
    }
    
    try {
      if (restaurant.value.isFavorite) {
        // 取消收藏
        await request({
          url: `/favorites/${restaurantId}`,
          method: 'DELETE',
          headers: {
            Authorization: `Bearer ${userInfo.value.token}`
          }
        });
        
        ElMessage.success('Unbookmarked successfully');
        restaurant.value.isFavorite = false;
      } else {
        // 添加收藏
        await request({
          url: '/favorites',
          method: 'POST',
          headers: {
            Authorization: `Bearer ${userInfo.value.token}`
          },
          data: {
            restaurantId: parseInt(restaurantId)
          }
        });
        
        ElMessage.success('Bookmarked successfully');
        restaurant.value.isFavorite = true;
      }
    } catch (error) {
      ElMessage.error(error.response?.data?.message || 'operation failed, please try again later');
      console.error('operation failed', error);
    }
  };
  
  // 开始预订流程
  const startReservation = () => {
    if (!isUserLoggedIn.value) {
      ElMessage.warning('Please login first to book the restaurant');
      router.push('/login');
      return;
    }
    
    ElMessage.info('The booking function is coming soon, please stay tuned');
  };
  
  
  const filterReviewsByRating = (rating) => {
    const newRating = rating === reviewsRating.value ? null : rating;
    
    if (newRating === reviewsRating.value) return;
    
    reviewsLoading.value = true;
    
    reviewsRating.value = newRating;
    
    setTimeout(() => {
      reviewsPage.value = 1;
      fetchReviews(false, true);
    }, 100);
  };
  

  const fetchReviews = async (loadMore = false, isFilter = false) => {
    if (loadMore) {
      reviewsPage.value++;
    } else if (!isFilter) {
      reviewsPage.value = 1;
      reviewsLoading.value = true;
    }
    
    try {
      const res = await request({
        url: `/restaurants/${restaurantId}/reviews`,
        method: 'GET',
        params: {
          page: reviewsPage.value,
          pageSize: reviewsPageSize.value,
          rating: reviewsRating.value || undefined
        }
      });
      
      if (loadMore) {
        reviewsList.value = [...reviewsList.value, ...res.data.list];
      } else {
        const newReviews = res.data.list || [];
        
        if (isFilter) {
          const reviewsContainer = document.querySelector('.reviews-list');
          if (reviewsContainer) {
            reviewsContainer.style.opacity = '0.3';
            reviewsContainer.style.transition = 'opacity 0.3s ease';
            
            setTimeout(() => {
              reviewsList.value = newReviews;
              setTimeout(() => {
                if (reviewsContainer) {
                  reviewsContainer.style.opacity = '1';
                }
                reviewsLoading.value = false;
              }, 50);
            }, 300);
          } else {
            reviewsList.value = newReviews;
            reviewsLoading.value = false;
          }
        } else {
          reviewsList.value = newReviews;
          reviewsLoading.value = false;
        }
      }
      
      reviewsTotal.value = res.data.total || 0;
    } catch (error) {
      console.error('review error', error);
      ElMessage.error('review error');
      reviewsLoading.value = false;
    }
  };
  
  // 加载更多评价
  const loadMoreReviews = () => {
    if (reviewsList.value.length < reviewsTotal.value) {
      fetchReviews(true);
    }
  };
  
  // 格式化评价时间
  const formatReviewTime = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' });
  };
  
  // 格式化营业时间
  const formatBusinessHours = (hours) => {
    if (!hours) return 'No business hours information available';
    
    const time = [];
    hours.split('|').map((item,index) => {
      time[index] = item;
    });
    return time.join(' / ');
  };
  
  // 格式化选择的日期和类型
  const formatSelectedDay = (date) => {
    if (!date) return '';
    
    const dayOfWeek = date.getDay(); // 0是周日，6是周六
    const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const formattedDate = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
    
    return `${formattedDate} ${dayNames[dayOfWeek]}${isWeekend ? ' (Weekend)' : ' (Weekday)'}`;
  };
  
  // 获取状态编码
  const getStatusCode = (status) => {
    const statusMap = {
      'Pending': 'pending',
      'Approved': 'approved',
      'Closed': 'closed',
      'Operating': 'operating'
    };
    
    return statusMap[status] || 'unknown';
  };
  
  // 打开谷歌地图导航
  const openGoogleMapsNavigation = () => {
    if (restaurant.value.latitude && restaurant.value.longitude) {
      const url = `https://www.google.com/maps/dir/?api=1&destination=${restaurant.value.latitude},${restaurant.value.longitude}`;
      window.open(url, '_blank');
    } else {
      ElMessage.warning('no location information available');
    }
  };
  
  // 预订相关状态
  const timeSelectionVisible = ref(false);
  const selectedTable = ref(null);
  const selectedDate = ref(new Date());
  const selectedTimeSlots = ref([]);
  const availableTimeSlots = ref([]);
  const loadingTimeSlots = ref(false);
  const bookedTimeSlots = ref([]);
  const personCount = ref(1);
  const reservationRemarks = ref('');
  
  // 选择桌位
  const selectTable = (table) => {
    if (!isUserLoggedIn.value) {
      ElMessage.warning('Please login first to book the restaurant');
      router.push('/login');
      return;
    }
    
    selectedTable.value = table;
    // 默认选择明天而不是今天
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    selectedDate.value = tomorrow;
    selectedTimeSlots.value = [];
    personCount.value = Math.min(table.capacity || 4, 4); // 默认设置人数为4或桌子容量较小值
    reservationRemarks.value = '';
    timeSelectionVisible.value = true;
    
    // 加载该桌位的预订情况
    fetchTableReservations();
  };
  
  // 禁用当天及之前的日期
  const disabledDate = (time) => {
    // 获取明天的零点时间（排除时分秒）
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    
    // 禁用所有早于明天的日期（包括今天）
    return time.getTime() < tomorrow.getTime();
  };
  
  // 处理日期变化
  const handleDateChange = () => {
    selectedTimeSlots.value = []; // 清空已选时间
    generateTimeSlots(); // 重新生成当天的时间槽
    fetchTableReservations(); // 获取当天的预约情况
  };
  
  // 生成时间选择槽
  const generateTimeSlots = () => {
    availableTimeSlots.value = [];
    
    // 默认营业时间 11:00-22:00，如果餐厅有营业时间则解析
    let startHour = 11;
    let endHour = 22;
    
    if (restaurant.value.businessHours) {
      // 解析营业时间字符串，格式为 "周一至周五 11:00-22:00|周末 10:00-23:00"
      const businessHoursParts = restaurant.value.businessHours.split('|');
      
      // 判断当前选择的日期是否为周末
      const selectedDay = selectedDate.value.getDay(); // 0是周日，6是周六
      const isWeekend = selectedDay === 0 || selectedDay === 6;
      
      // 根据是否为周末选择对应的营业时间段
      let todayHours;
      if (isWeekend) {
        // 查找包含"Weekends"的时间段
        todayHours = businessHoursParts.find(hours => 
          hours.includes('Weekends'));
      } else {
        // 查找包含"Monday to Friday"的时间段
        todayHours = businessHoursParts.find(hours => 
          hours.includes('Monday to Friday'));
      }
      
      // 如果没有找到匹配的时间段，则使用第一个时间段作为默认值
      if (!todayHours && businessHoursParts.length > 0) {
        todayHours = businessHoursParts[0];
      }
      
      // 解析时间
      if (todayHours) {
        const timeMatch = todayHours.match(/(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})/);
        if (timeMatch) {
          startHour = parseInt(timeMatch[1]);
          endHour = parseInt(timeMatch[3]);
        }
      }
    }
    
    // 生成时间槽，每小时一个
    for (let hour = startHour; hour < endHour; hour++) {
      const timeValue = `${hour.toString().padStart(2, '0')}:00`;
      availableTimeSlots.value.push({
        label: `${hour}:00-${hour+1}:00`,
        value: timeValue,
        hour: hour,
        disabled: false // 初始状态都是可用的，稍后在fetchTableReservations中判断禁用
      });
    }
  };
  
  // 获取桌位预订情况
  const fetchTableReservations = async () => {
    if (!selectedTable.value || !selectedDate.value) return;
    
    loadingTimeSlots.value = true;
    
    try {
      // 获取选择日期的字符串表示，格式为 YYYY-MM-DD
      const selectedDateString = selectedDate.value.toISOString().split('T')[0];
      
      const response = await request({
        url: `/reservations/table/${selectedTable.value.id}/future`,
        method: 'GET',
        headers: {
          Authorization: `Bearer ${userInfo.value.token}`
        },
        params: {
          date: selectedDateString
        }
      });
      
      // 更新已预订时间槽
      bookedTimeSlots.value = response.data || [];
      
      // 初始化所有时间槽为可用状态
      availableTimeSlots.value.forEach(slot => {
        slot.disabled = false;
      });
      
      // 遍历所有已预订的时间段，禁用对应的时间槽
      bookedTimeSlots.value.forEach(booking => {
        if (!booking.reservationTime) return;
        
        // 解析预订时间和日期
        const bookingDate = new Date(booking.reservationTime);
        const bookingDateString = bookingDate.toISOString().split('T')[0];
        
        // 只处理当天的预订
        if (bookingDateString === selectedDateString) {
          const reservationHour = bookingDate.getUTCHours();
          const duration = booking.reservationDate || 1; // 使用预订时长，默认为1小时
          
          // 禁用当前预订占用的所有时间槽
          availableTimeSlots.value.forEach(slot => {
            if (slot.hour >= reservationHour && slot.hour < (reservationHour + duration)) {
              slot.disabled = true;
            }
          });
        }
      });
    } catch (error) {
      console.error('get reservation information error', error);
      ElMessage.error('get reservation information error');
    } finally {
      loadingTimeSlots.value = false;
    }
  };
  
  // 处理时间选择
  const handleTimeSelection = (timeSlot) => {
    const index = selectedTimeSlots.value.findIndex(slot => slot.value === timeSlot.value);
    
    if (index > -1) {
      // 如果已选择，则取消选择
      selectedTimeSlots.value.splice(index, 1);
    } else {
      // 如果未选择，则添加到选择列表
      selectedTimeSlots.value.push(timeSlot);
    }
    
    // 排序选中的时间段
    selectedTimeSlots.value.sort((a, b) => a.hour - b.hour);
    
    // 检查是否连续
    validateTimeSelection();
  };
  
  // 验证时间选择是否连续
  const validateTimeSelection = () => {
    if (selectedTimeSlots.value.length <= 1) {
      return true;
    }
    
    // 复制并按小时排序
    const sortedSlots = [...selectedTimeSlots.value].sort((a, b) => a.hour - b.hour);
    
    // 检查时间是否连续
    for (let i = 1; i < sortedSlots.length; i++) {
      if (sortedSlots[i].hour !== sortedSlots[i-1].hour + 1) {
        ElMessage.warning('Please select consecutive time slots');
        // 移除最后添加的这个不连续的时间段
        selectedTimeSlots.value = selectedTimeSlots.value.filter(
          slot => slot.value !== sortedSlots[i].value
        );
        return false;
      }
    }
    
    return true;
  };
  
  // 获取选择的时间范围显示
  const selectedTimeRange = computed(() => {
    if (!selectedTimeSlots.value.length) return '';
    
    // 按小时排序
    const sortedSlots = [...selectedTimeSlots.value].sort((a, b) => a.hour - b.hour);
    
    if (sortedSlots.length === 1) {
      return sortedSlots[0].label;
    }
    
    const startHour = sortedSlots[0].hour;
    const endHour = sortedSlots[sortedSlots.length - 1].hour + 1;
    
    return `${startHour}:00-${endHour}:00`;
  });
  
  // 确认预订
  const confirmReservation = async () => {
    if (!selectedTable.value || !selectedDate.value || selectedTimeSlots.value.length === 0) {
      ElMessage.warning('Please select booking time');
      return;
    }
    
    if (personCount.value <= 0 || personCount.value > selectedTable.value.capacity) {
      ElMessage.warning(`用餐人数必须在1至${selectedTable.value.capacity}人之间`);
      return;
    }
    
    try {
      const dateStr = selectedDate.value.toISOString().split('T')[0];
      
      // 按小时排序
      const sortedSlots = [...selectedTimeSlots.value].sort((a, b) => a.hour - b.hour);
      const startTime = sortedSlots[0].value;
      
      // 计算预约时长（小时数）
      const reservationDuration = sortedSlots.length;
      
      // 组装ISO格式的时间字符串 "2023-04-20T18:30:00Z"
      const reservationTime = `${dateStr}T${startTime}:00Z`;
      
      await request({
        url: '/reservations',
        method: 'POST',
        headers: {
          Authorization: `Bearer ${userInfo.value.token}`
        },
        data: {
          restaurantId: parseInt(restaurantId),
          tableId: parseInt(selectedTable.value.id),
          reservationTime: reservationTime,
          reservationDate: reservationDuration, // 使用reservationDate作为持续时长属性
          personCount: personCount.value,
          remarks: reservationRemarks.value
        }
      });
      
      ElMessage.success('Booking successful');
      timeSelectionVisible.value = false;
      
      // 清空选择
      selectedTimeSlots.value = [];
      personCount.value = 1;
      reservationRemarks.value = '';
      
      // 预订成功后可以跳转到我的预订页面或留在当前页面
      // router.push('/my-reservations');
    } catch (error) {
      ElMessage.error(error.response?.data?.message || 'booking failed, please try again later');
      console.error('booking failed', error);
    }
  };
  
  // 监听日期变化生成时间槽
  watch(selectedDate, () => {
    // 清空之前的选择
    selectedTimeSlots.value = [];
    generateTimeSlots();
  });
  
  // 挂载时生成默认时间槽
  onMounted(() => {
    fetchRestaurantDetail();
    generateTimeSlots();
    fetchReviews();
  });
  
  // 视频控制相关方法
  const playVideo = (event) => {
    event.preventDefault();
    const videoContainer = event.currentTarget;
    const video = videoContainer.querySelector('video');
    
    if (video) {
      // 处理视频播放/暂停逻辑
      if (video.paused) {
        // 如果视频是暂停状态，播放视频
        videoContainer.classList.add('playing');
        video.play().catch(error => {
          console.error('video playback failed:', error);
          videoContainer.classList.remove('playing');
        });
        
        // 添加视频结束事件监听器
        video.onended = () => {
          videoContainer.classList.remove('playing');
        };
      } else {
        // 如果视频正在播放，暂停视频
        video.pause();
        videoContainer.classList.remove('playing');
      }
    }
  };
  </script>
  
  <style lang="scss" scoped>
  // 变量定义
  $primary-color: #e02020;
  $secondary-color: #fff0f0;
  $text-primary: #333;
  $text-secondary: #666;
  $text-light: #999;
  $border-radius: 8px;
  $box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  $gradient-primary: linear-gradient(135deg, $primary-color, #ff6b6b);
  
  .restaurant-detail-container {
    position: relative;
    background-color: #f8f9fa;
    min-height: 100vh;
  }
  
  // 顶部导航栏
  .detail-header {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    z-index: 10;
    padding: 20px;
    
    .header-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .back-button, .favorite-button, .share-button {
        width: 44px;
        height: 44px;
        background-color: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(10px);
        border: none;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        color: $text-primary;
        transition: all 0.3s;
        
        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        &.is-favorite {
          background-color: $primary-color;
          color: white;
        }
      }
      
      .actions-right {
        display: flex;
        gap: 10px;
      }
    }
  }
  
  // 餐厅照片画廊
  .restaurant-gallery {
    position: relative;
    height: 450px;
    overflow: hidden;
    
    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.3);
      z-index: 1;
    }
    
    .el-carousel {
      height: 100%;
      --el-carousel-indicator-width: 30px;
      --el-carousel-indicator-height: 3px;
      
      :deep(.el-carousel__container) {
        height: 100%;
      }
      
      :deep(.el-carousel__indicator--active) {
        .el-carousel__button {
          background-color: #fff;
        }
      }
      
      :deep(.el-carousel__arrow) {
        background-color: rgba(255, 255, 255, 0.8);
        backdrop-filter: blur(10px);
        color: $text-primary;
        border-radius: 50%;
        width: 50px;
        height: 50px;
        
        &:hover {
          background-color: white;
        }
      }
      
      :deep(.el-carousel__indicators--outside) {
        bottom: 20px;
        z-index: 10;
      }
    }
    
    .gallery-item {
      width: 100%;
      height: 100%;
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      transition: transform 0.8s ease;
      
      &:hover {
        transform: scale(1.05);
      }
    }
    
    .restaurant-title-overlay {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      padding: 40px 30px 50px;
      background: linear-gradient(to top, rgba(0, 0, 0, 0.8), transparent);
      color: #fff;
      z-index: 5;
      
      h1 {
        font-size: 42px;
        font-weight: 800;
        margin: 0 0 10px;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        animation: fadeInUp 0.5s ease-out forwards;
      }
      
      .quick-info {
        display: flex;
        align-items: center;
        gap: 15px;
        animation: fadeInUp 0.5s 0.1s ease-out forwards;
        opacity: 0;
        
        .info-item {
          display: flex;
          align-items: center;
          gap: 5px;
          
          .el-icon {
            font-size: 16px;
          }
          
          &.cuisine {
            background-color: rgba(255, 255, 255, 0.2);
            padding: 4px 12px;
            border-radius: 20px;
            backdrop-filter: blur(5px);
          }
        }
        
        .rating-display {
          display: flex;
          align-items: center;
          gap: 8px;
          background-color: rgba(255, 255, 255, 0.2);
          padding: 4px 12px;
          border-radius: 20px;
          backdrop-filter: blur(5px);
          
          .rating-value {
            font-weight: 700;
            color: #ffcc00;
            font-size: 18px;
          }
          
          .review-count {
            font-size: 14px;
            opacity: 0.8;
          }
        }
      }
    }
    
    .no-photos {
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background-color: #eee;
      color: $text-light;
      
      .el-icon {
        font-size: 48px;
        margin-bottom: 10px;
      }
    }
  }
  
  // 餐厅基本信息卡片
  .restaurant-info-card {
    background-color: white;
    border-radius: $border-radius;
    margin: 30px 20px 20px;
    padding: 30px;
    position: relative;
    z-index: 5;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
    
    &::before {
      content: '';
      position: absolute;
      top: -15px;
      left: 40px;
      width: 80px;
      height: 5px;
      background: $gradient-primary;
      border-radius: 5px;
    }
    
    .info-section {
      margin-bottom: 30px;
      
      .info-row {
        display: flex;
        gap: 15px;
        margin-bottom: 20px;
        color: $text-secondary;
        padding: 10px 15px;
        background-color: #f9f9fa;
        border-radius: 10px;
        transition: all 0.3s;
        
        &:hover {
          background-color: $secondary-color;
          transform: translateX(5px);
        }
        
        .el-icon {
          color: $primary-color;
          flex-shrink: 0;
          font-size: 20px;
        }
      }
    }
    
    .description-section {
      position: relative;
      
      h3 {
        font-size: 22px;
        margin: 0 0 15px;
        color: $text-primary;
        font-weight: 600;
        display: inline-flex;
        position: relative;
        
        &::after {
          content: '';
          position: absolute;
          bottom: -5px;
          left: 0;
          width: 100%;
          height: 2px;
          background: $gradient-primary;
          border-radius: 2px;
        }
      }
      
      p {
        color: $text-secondary;
        line-height: 1.8;
        margin: 0;
        font-size: 16px;
        padding: 0 0 0 15px;
        border-left: 3px solid $secondary-color;
      }
    }
  }
  
  // 桌位信息部分
  .tables-section {
    background-color: white;
    border-radius: $border-radius;
    margin: 0 20px 30px;
    padding: 30px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
    position: relative;
    overflow: hidden;
    
    &::before {
      content: '';
      position: absolute;
      top: 0;
      right: 0;
      width: 150px;
      height: 150px;
      background: radial-gradient(circle, $secondary-color 0%, rgba(255,255,255,0) 70%);
      border-radius: 50%;
      opacity: 0.7;
    }
    
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      
      h2 {
        margin: 0;
        font-size: 24px;
        color: $text-primary;
        font-weight: 700;
        position: relative;
        padding-left: 15px;
        
        &::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          width: 5px;
          height: 100%;
          background: $gradient-primary;
          border-radius: 5px;
        }
      }
      
      .reserve-button {
        background: $gradient-primary;
        border: none;
        padding: 12px 25px;
        border-radius: 30px;
        font-size: 16px;
        font-weight: 500;
        
        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 8px 20px rgba($primary-color, 0.3);
        }
      }
    }
    
    .tables-container {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 25px;
      
      .table-card {
        border: none;
        border-radius: 16px;
        overflow: visible;
        position: relative;
        cursor: pointer;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
        transition: all 0.4s cubic-bezier(0.215, 0.61, 0.355, 1);
        padding: 0;
        
        &::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: radial-gradient(circle at top right, rgba(255, 255, 255, 0.8), transparent 70%);
          border-radius: 16px;
          opacity: 0.6;
          z-index: 0;
        }
        
        &:hover {
          transform: translateY(-12px) scale(1.03);
          box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
          
          .table-actions {
            opacity: 1;
            transform: translateY(0);
          }
          
          .table-header {
            .table-icon-container {
              transform: translateY(-5px) scale(1.1);
            }
          }
          
          .table-type-tag {
            background: $gradient-primary;
            color: white;
          }
        }
        
        &.vip-table {
          border: 2px solid #ffc107;
          background: linear-gradient(145deg, #fffaf0, #fff5e6);
          box-shadow: 0 10px 25px rgba(255, 153, 0, 0.15);
          
          &::before {
            background: radial-gradient(circle at top right, rgba(255, 246, 220, 0.8), transparent 80%);
          }
          
          .vip-ribbon {
            position: absolute;
            top: 20px;
            right: -35px;
            background: linear-gradient(45deg, #ffc107, #ff9800);
            color: white;
            font-weight: bold;
            padding: 5px 40px;
            transform: rotate(45deg);
            z-index: 10;
            font-size: 14px;
            box-shadow: 0 2px 10px rgba(255, 153, 0, 0.3);
            letter-spacing: 2px;
          }
          
          .table-actions .el-button {
            background: linear-gradient(45deg, #ffc107, #ff9800);
            border-color: #ff9800;
            color: white;
            
            &:hover {
              box-shadow: 0 5px 15px rgba(255, 153, 0, 0.3);
              background: linear-gradient(45deg, #ff9800, #ffc107);
            }
          }
        }
        
        &.large-table {
          border: 2px solid #3f51b5;
          background: linear-gradient(145deg, #f0f3ff, #e6ebff);
          box-shadow: 0 10px 25px rgba(63, 81, 181, 0.15);
          
          &::before {
            background: radial-gradient(circle at top right, rgba(220, 230, 255, 0.8), transparent 80%);
          }
          
          .large-ribbon {
            position: absolute;
            top: 12px;
            right: -30px;
            background: linear-gradient(45deg, #3f51b5, #5c6bc0);
            color: white;
            font-weight: bold;
            padding: 3px 30px;
            transform: rotate(45deg);
            z-index: 10;
            font-size: 13px;
            box-shadow: 0 2px 10px rgba(63, 81, 181, 0.3);
          }
          
          .table-actions .el-button {
            background: linear-gradient(45deg, #3f51b5, #5c6bc0);
            border-color: #3f51b5;
            color: white;
            
            &:hover {
              box-shadow: 0 5px 15px rgba(63, 81, 181, 0.3);
              background: linear-gradient(45deg, #5c6bc0, #3f51b5);
            }
          }
        }
        
        &.standard-table {
          border: 2px solid #26c6da;
          background: linear-gradient(145deg, #f0fafb, #e6f7f9);
          box-shadow: 0 10px 25px rgba(38, 198, 218, 0.1);
          
          &::before {
            background: radial-gradient(circle at top right, rgba(220, 245, 255, 0.8), transparent 80%);
          }
        }
        
        .table-status {
          position: absolute;
          top: 15px;
          left: 15px;
          z-index: 5;
          
          .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.1);
            
            &.available {
              background: linear-gradient(45deg, #4caf50, #8bc34a);
              color: white;
            }
            
            &.unavailable {
              background: linear-gradient(45deg, #f44336, #ff5252);
              color: white;
            }
          }
        }
        
        .table-header {
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 30px 20px 15px;
          position: relative;
          z-index: 2;
          
          .table-icon-container {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.9);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            
            .table-icon {
              font-size: 30px;
              
              &.vip {
                color: #ffc107;
              }
              
              &.large {
                color: #3f51b5;
              }
              
              &.standard {
                color: #26c6da;
              }
            }
          }
          
          .table-type-tag {
            background-color: #f5f5f5;
            color: #333;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 10px;
            transition: all 0.3s ease;
          }
        }
        
        .table-body {
          padding: 0 20px 20px;
          position: relative;
          z-index: 2;
          
          .table-features {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 15px;
            
            .feature {
              background-color: #f0f0f0;
              padding: 3px 10px;
              border-radius: 15px;
              font-size: 12px;
              color: #555;
              
              span {
                display: block;
              }
            }
          }
          
          .table-info {
            background-color: rgba(255, 255, 255, 0.7);
            border-radius: 10px;
            padding: 12px;
            
            .table-capacity, .table-availability {
              display: flex;
              align-items: center;
              gap: 10px;
              margin-bottom: 8px;
              color: $text-secondary;
              font-size: 14px;
              
              &:last-child {
                margin-bottom: 0;
              }
              
              .el-icon {
                color: $primary-color;
                background-color: $secondary-color;
                width: 28px;
                height: 28px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
              }
            }
          }
        }
        
        .table-actions {
          padding: 0 20px 20px;
          opacity: 0.9;
          transform: translateY(5px);
          transition: all 0.3s ease;
          position: relative;
          z-index: 2;
          
          .el-button {
            width: 100%;
            height: 44px;
            font-size: 16px;
            font-weight: 500;
            border-radius: 10px;
            transition: all 0.3s ease;
            
            &:hover {
              transform: translateY(-3px);
              box-shadow: 0 8px 15px rgba($primary-color, 0.2);
            }
          }
        }
      }
      
      .no-tables {
        grid-column: 1 / -1;
        padding: 40px 0;
      }
    }
  }
  
  // 餐厅地图位置
  .map-section {
    background-color: white;
    border-radius: $border-radius;
    margin: 0 20px 20px;
    padding: 25px;
    box-shadow: $box-shadow;
    
    h2 {
      margin: 0 0 20px;
      font-size: 22px;
      color: $text-primary;
      font-weight: 600;
    }
    
    .map-container {
      display: flex;
      flex-direction: column;
      gap: 15px;
      
      .google-map-container {
        height: 300px;
        border-radius: $border-radius;
        overflow: hidden;
        position: relative;
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        
        iframe {
          width: 100%;
          height: 100%;
          border: none;
          position: relative;
          z-index: 1;
          transition: all 0.3s ease;
          
          &:hover {
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
          }
        }
        
        &::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 4px;
          background: $gradient-primary;
          z-index: 2;
          border-radius: $border-radius $border-radius 0 0;
        }
      }
      
      .map-placeholder {
        height: 300px;
        background-color: #f5f5f5;
        border-radius: $border-radius;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: $text-light;
        
        .el-icon {
          font-size: 36px;
          margin-bottom: 10px;
        }
      }
      
      .address-detail {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 15px;
        background-color: #f9f9fa;
        border-radius: 10px;
        
        p {
          display: flex;
          align-items: center;
          gap: 8px;
          color: $text-secondary;
          margin: 0;
          font-weight: 500;
          
          .el-icon {
            color: $primary-color;
          }
        }
        
        .el-button {
          display: flex;
          align-items: center;
          gap: 8px;
          transition: all 0.3s ease;
          
          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba($primary-color, 0.2);
          }
        }
      }
    }
  }
  
  // 评论区域
  .reviews-section {
    background-color: white;
    border-radius: $border-radius;
    margin: 0 20px 80px;
    padding: 25px;
    box-shadow: $box-shadow;
    
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      
      h2 {
        margin: 0;
        font-size: 22px;
        color: $text-primary;
        font-weight: 600;
      }
    }
    
    .rating-filter {
      display: flex;
      align-items: center;
      margin-bottom: 15px;
      background-color: #f8f9fa;
      padding: 12px 15px;
      border-radius: 10px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
      transition: all 0.3s ease;
      
      .filter-label {
        margin-right: 10px;
        font-weight: 600;
      }
      
      .rating-buttons {
        display: flex;
        gap: 5px;
        flex-wrap: wrap;
        
        .el-button {
          padding: 5px 10px;
          border-radius: 15px;
          transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
          position: relative;
          overflow: hidden;
          
          &::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: all 0.5s;
          }
          
          &.active-rating {
            background-color: $primary-color;
            color: white;
            box-shadow: 0 3px 10px rgba($primary-color, 0.3);
            font-weight: 500;
            transform: translateY(-2px);
            
            .el-icon {
              animation: pulse 1.5s infinite;
            }
          }
          
          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
            
            &::before {
              left: 100%;
            }
          }
        }
      }
    }
  
    .reviews-container {
      .no-reviews {
        padding: 30px 0;
      }
      
      .reviews-list {
        transition: opacity 0.3s ease, transform 0.3s ease;
        min-height: 200px; /* 添加最小高度避免内容变化时的跳动 */
        
        .review-item {
          margin-bottom: 30px;
          padding-bottom: 25px;
          border-bottom: 1px solid #eee;
          transition: transform 0.3s ease, opacity 0.3s ease;
          
          &:last-child {
            margin-bottom: 20px;
          }
          
          .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            
            .user-info {
              display: flex;
              align-items: center;
              gap: 12px;
              
              .el-avatar {
                border: 2px solid #f5f5f5;
                box-shadow: 0 3px 8px rgba(0, 0, 0, 0.1);
              }
              
              .user-details {
                .user-name {
                  font-size: 16px;
                  font-weight: 600;
                  color: $text-primary;
                  margin-bottom: 4px;
                }
                
                .review-time {
                  font-size: 12px;
                  color: $text-light;
                }
              }
            }
            
            .review-rating {
              display: flex;
              align-items: center;
              gap: 8px;
              
              .rating-value {
                font-size: 18px;
                font-weight: 700;
                color: #ffcc00;
              }
            }
          }
          
          .review-content {
            p {
              margin: 0 0 15px;
              line-height: 1.6;
              color: $text-secondary;
              font-size: 15px;
              position: relative;
              padding-left: 15px;
              
              &::before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 3px;
                background-color: #f0f0f0;
                border-radius: 3px;
              }
            }
            
            .review-media {
              display: flex;
              flex-wrap: wrap;
              gap: 10px;
              margin-bottom: 15px;
              
              .review-media-item {
                width: 150px;
                height: 150px;
                border-radius: 8px;
                overflow: hidden;
                position: relative;
                box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
                transition: all 0.3s ease;
                
                &:hover {
                  transform: scale(1.03);
                  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
                }
                
                .image-error {
                  height: 100%;
                  width: 100%;
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                  justify-content: center;
                  background-color: #f5f5f5;
                  color: #999;
                  
                  .el-icon {
                    font-size: 40px;
                    margin-bottom: 10px;
                  }
                  
                  span {
                    font-size: 14px;
                  }
                }
                
                &.video-container {
                  background-color: #000;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  cursor: pointer;
                  position: relative;
                  
                  .review-video {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    z-index: 1;
                  }
                  
                  /* 增强视频控件可见性 */
                  video::-webkit-media-controls {
                    z-index: 10;
                  }
                }
              }
            }
            
            .review-videos {
              display: none; // 不再单独使用
            }
          }
        }
        
        .load-more {
          display: flex;
          justify-content: center;
          margin-top: 20px;
          
          .el-button {
            padding: 10px 30px;
            transition: all 0.3s;
            
            &:hover {
              transform: translateY(-2px);
              box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            }
          }
        }
      }
    }
  }
  
  // 底部操作栏
  .bottom-action-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background-color: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    box-shadow: 0 -5px 20px rgba(0, 0, 0, 0.08);
    padding: 15px 20px;
    z-index: 50;
    display: flex;
    justify-content: center;
    
    .reserve-action-btn {
      background: $gradient-primary;
      border: none;
      width: 80%;
      max-width: 400px;
      height: 52px;
      font-size: 18px;
      font-weight: 600;
      border-radius: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      transition: all 0.3s cubic-bezier(0.165, 0.84, 0.44, 1);
      position: relative;
      overflow: hidden;
      
      &::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: all 0.5s;
      }
      
      &:hover {
        transform: translateY(-2px) scale(1.02);
        box-shadow: 0 10px 25px rgba($primary-color, 0.3);
        
        &::before {
          left: 100%;
        }
      }
      
      .el-icon {
        font-size: 20px;
      }
    }
  }
  
  // 响应式调整
  @media (max-width: 768px) {
    .restaurant-gallery {
      height: 250px;
    }
    
    .restaurant-info-card {
      .restaurant-meta {
        .restaurant-name {
          font-size: 24px;
        }
      }
    }
    
    .tables-section {
      .tables-container {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
      }
    }
  }
  
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  // 时间选择对话框样式
  .time-selection-dialog {
    :deep(.el-dialog) {
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1), 0 8px 20px rgba(0, 0, 0, 0.08);
    }
    
    :deep(.el-dialog__header) {
      padding: 20px 24px;
      border-bottom: 1px solid #f5f5f5;
      margin-right: 0;
      position: relative;
      background: linear-gradient(to right, lighten($primary-color, 40%), white);
      
      &::after {
        content: '';
        position: absolute;
        bottom: -1px;
        left: 0;
        width: 100px;
        height: 3px;
        background: $gradient-primary;
        border-radius: 3px 3px 0 0;
      }
      
      .el-dialog__title {
        font-size: 22px;
        color: $text-primary;
        font-weight: 700;
        position: relative;
        
        &::before {
          content: '';
          position: absolute;
          left: -12px;
          top: 0;
          height: 100%;
          width: 4px;
          background: $primary-color;
          border-radius: 2px;
        }
      }
      
      .el-dialog__headerbtn {
        top: 23px;
        right: 24px;
        
        .el-dialog__close {
          color: $text-secondary;
          font-size: 22px;
          transition: all 0.3s;
          
          &:hover {
            color: $primary-color;
            transform: rotate(90deg);
          }
        }
      }
    }
    
    :deep(.el-dialog__body) {
      padding: 0;
    }
    
    :deep(.el-dialog__footer) {
      padding: 20px 24px;
      border-top: 1px solid #f5f5f5;
      background-color: rgba(249, 250, 251, 0.8);
      backdrop-filter: blur(10px);
    }
    
    .time-selection-content {
      .selected-table-info {
        display: flex;
        gap: 24px;
        padding: 24px;
        position: relative;
        border-bottom: 1px dashed #eaeaea;
        background: linear-gradient(to right, #fcfcfc, white);
        
        .table-icon-wrapper {
          position: relative;
          
          &::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 100px;
            height: 100px;
            background: radial-gradient(circle, rgba($primary-color, 0.08) 0%, rgba(255, 255, 255, 0) 70%);
            border-radius: 50%;
            z-index: 0;
          }
        }
        
        .table-icon {
          background-color: #f8f9fa;
          width: 80px;
          height: 80px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          position: relative;
          box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
          border: 5px solid white;
          transition: all 0.3s;
          z-index: 1;
          
          &:hover {
            transform: scale(1.05);
          }
          
          .el-icon {
            font-size: 36px;
            color: $primary-color;
          }
          
          &.vip-icon {
            background: linear-gradient(135deg, #fff9e6, #fff5e5);
            border-color: #fffbf0;
            
            .el-icon {
              color: #ffc107;
            }
            
            &::after {
              content: 'VIP';
              position: absolute;
              bottom: -10px;
              right: -10px;
              background: linear-gradient(45deg, #ffc107, #ff9800);
              color: white;
              font-size: 12px;
              font-weight: bold;
              padding: 3px 8px;
              border-radius: 10px;
              box-shadow: 0 3px 8px rgba(255, 152, 0, 0.2);
            }
          }
          
          &.large-icon {
            background: linear-gradient(135deg, #f0f3ff, #ebeeff);
            border-color: #f7f8ff;
            
            .el-icon {
              color: #3f51b5;
            }
          }
          
          &.standard-icon {
            background: linear-gradient(135deg, #e8f9fb, #ecfeff);
            border-color: #f0fdff;
            
            .el-icon {
              color: #26c6da;
            }
          }
        }
        
        .table-details {
          flex: 1;
          
          h3 {
            margin: 0 0 8px;
            font-size: 22px;
            color: $text-primary;
            font-weight: 700;
            position: relative;
            display: inline-block;
            
            &::after {
              content: '';
              position: absolute;
              bottom: -2px;
              left: 0;
              width: 100%;
              height: 2px;
              background: $gradient-primary;
              border-radius: 2px;
            }
          }
          
          p {
            margin: 0 0 12px;
            color: $text-secondary;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            
            .el-icon {
              color: $primary-color;
              font-size: 18px;
            }
          }
          
          .table-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            
            .tag {
              padding: 4px 10px;
              border-radius: 12px;
              font-size: 12px;
              font-weight: 500;
              
              &.vip-tag {
                background-color: rgba(255, 193, 7, 0.15);
                color: #ffab00;
              }
              
              &.large-tag {
                background-color: rgba(63, 81, 181, 0.15);
                color: #3949ab;
              }
              
              &.standard-tag {
                background-color: rgba(38, 198, 218, 0.15);
                color: #00acc1;
              }
            }
          }
        }
      }
      
      .selection-container {
        display: grid;
        grid-template-columns: 240px 1fr;
        gap: 0;
        border-bottom: 1px dashed #eaeaea;
        
        .date-selection {
          padding: 24px;
          border-right: 1px dashed #eaeaea;
          background-color: #fcfcfc;
          
          h4 {
            font-size: 17px;
            margin: 0 0 16px;
            color: $text-primary;
            display: flex;
            align-items: center;
            gap: 8px;
            
            .el-icon {
              color: $primary-color;
            }
          }
          
          .el-date-picker {
            width: 100%;
          }
          
          .note {
            margin: 16px 0 0;
            color: $primary-color;
            font-size: 13px;
            padding: 8px 12px;
            border-radius: 8px;
            background-color: $secondary-color;
            display: flex;
            align-items: center;
            gap: 8px;
            
            .el-icon {
              color: $primary-color;
              font-size: 16px;
              flex-shrink: 0;
            }
          }
        }
        
        .time-slots {
          padding: 24px;
          
          h4 {
            font-size: 17px;
            margin: 0 0 16px;
            color: $text-primary;
            display: flex;
            align-items: center;
            gap: 8px;
            
            .el-icon {
              color: $primary-color;
            }
            
            .selected-time-range {
              font-size: 14px;
              background: $gradient-primary;
              color: white;
              padding: 4px 12px;
              border-radius: 20px;
              margin-left: 10px;
              display: inline-flex;
              align-items: center;
              gap: 5px;
              font-weight: 500;
              box-shadow: 0 3px 8px rgba($primary-color, 0.2);
            }
          }
          
          .time-hint, .selection-hint {
            margin: 0 0 8px;
            color: $text-secondary;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            
            .el-icon {
              color: $primary-color;
              font-size: 16px;
              flex-shrink: 0;
            }
          }
          
          .day-type-hint {
            margin: 0 0 8px;
            color: $primary-color;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 5px 12px;
            background-color: rgba($primary-color, 0.05);
            border-radius: 8px;
            
            .el-icon {
              color: $primary-color;
              font-size: 16px;
              flex-shrink: 0;
            }
          }
          
          .selection-hint {
            margin-bottom: 16px;
            color: #ff9800;
            background-color: rgba(255, 152, 0, 0.08);
            padding: 8px 12px;
            border-radius: 8px;
            
            .el-icon {
              color: #ff9800;
            }
          }
          
          .time-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
            gap: 12px;
            
            .el-button {
              padding: 14px 10px;
              border-radius: 10px;
              transition: all 0.3s ease;
              
              &.selected {
                background: $gradient-primary;
                color: white;
                border-color: $primary-color;
                transform: translateY(-3px);
                box-shadow: 0 8px 15px rgba($primary-color, 0.2);
                position: relative;
                font-weight: 600;
                
                &:not(:last-of-type) {
                  border-right: 2px solid white;
                }
                
                &:not(:first-of-type) {
                  border-left: 2px solid white;
                }
                
                &::after {
                  content: '';
                  position: absolute;
                  bottom: -5px;
                  left: 50%;
                  transform: translateX(-50%);
                  width: 8px;
                  height: 8px;
                  background-color: $primary-color;
                  border-radius: 50%;
                }
              }
              
              &:hover:not(.is-disabled):not(.selected) {
                background-color: $secondary-color;
                border-color: $primary-color;
                transform: translateY(-3px);
                box-shadow: 0 5px 10px rgba(0, 0, 0, 0.05);
              }
              
              &.is-disabled {
                opacity: 0.5;
                text-decoration: line-through;
                background-color: #f5f5f5;
                color: #aaa;
              }
            }
          }
        }
      }
      
      .reservation-details {
        padding: 24px;
        
        h4 {
          font-size: 17px;
          margin: 0 0 16px;
          color: $text-primary;
          display: flex;
          align-items: center;
          gap: 8px;
          position: relative;
          
          .el-icon {
            color: $primary-color;
          }
          
          &::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 100px;
            height: 2px;
            background: $gradient-primary;
            border-radius: 2px;
          }
        }
        
        .details-grid {
          display: grid;
          grid-template-columns: 1fr 2fr;
          gap: 20px;
          
          .detail-item {
            position: relative;
            
            label {
              display: block;
              margin-bottom: 10px;
              color: $text-secondary;
              font-weight: 500;
              font-size: 15px;
            }
            
            .el-input-number {
              width: 100%;
            }
            
            .capacity-info {
              display: block;
              margin-top: 8px;
              font-size: 13px;
              color: #9e9e9e;
            }
            
            :deep(.el-input__wrapper) {
              border-radius: 8px;
              box-shadow: 0 0 0 1px #e0e0e0;
              padding: 8px 12px;
              transition: all 0.3s;
              
              &.is-focus {
                box-shadow: 0 0 0 2px rgba($primary-color, 0.2);
              }
            }
            
            :deep(.el-textarea__inner) {
              border-radius: 10px;
              border: 1px solid #e0e0e0;
              padding: 12px;
              transition: all 0.3s;
              resize: none;
              
              &:focus {
                border-color: $primary-color;
                box-shadow: 0 0 0 2px rgba($primary-color, 0.1);
              }
            }
            
            :deep(.el-input-number__decrease),
            :deep(.el-input-number__increase) {
              border-color: #e0e0e0;
              color: $text-secondary;
              
              &:hover {
                color: $primary-color;
              }
            }
            
            &.remarks-item {
              grid-column: span 2;
            }
          }
        }
      }
    }
    
    .dialog-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .reservation-summary {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        max-width: 65%;
        
        .summary-item {
          font-size: 14px;
          
          .label {
            color: $text-secondary;
            margin-right: 5px;
          }
          
          .value {
            color: $text-primary;
            font-weight: 600;
          }
        }
      }
      
      .action-buttons {
        display: flex;
        gap: 12px;
        
        .el-button {
          border-radius: 8px;
          padding: 12px 24px;
          font-size: 16px;
          
          &.cancel-btn {
            color: $text-secondary;
            border-color: #e0e0e0;
            
            &:hover {
              color: $text-primary;
              border-color: #ccc;
              background-color: #f5f5f5;
            }
          }
          
          &.confirm-btn {
            background: $gradient-primary;
            border: none;
            padding: 12px 32px;
            box-shadow: 0 4px 10px rgba($primary-color, 0.2);
            
            &:hover:not(.is-disabled) {
              transform: translateY(-2px);
              box-shadow: 0 6px 15px rgba($primary-color, 0.3);
            }
            
            &.is-disabled {
              opacity: 0.7;
              background: #ccc;
            }
          }
        }
      }
    }
  }
  
  @keyframes rotate {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
  
  @keyframes pulse {
    0% {
      transform: scale(1);
      opacity: 1;
    }
    50% {
      transform: scale(1.1);
      opacity: 0.8;
    }
    100% {
      transform: scale(1);
      opacity: 1;
    }
  }
  
  // 评论区域的加载状态样式
  .reviews-section {
    :deep(.el-loading-mask) {
      background-color: rgba(255, 255, 255, 0.7);
      backdrop-filter: blur(3px);
      border-radius: $border-radius;
      transition: opacity 0.3s ease;
      
      .el-loading-spinner {
        .circular {
          animation: rotate 1.5s linear infinite;
        }
        
        .el-loading-text {
          color: $primary-color;
          font-weight: 500;
          margin-top: 8px;
        }
      }
    }
  }
  </style>