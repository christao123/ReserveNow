# 餐厅预订系统API接口文档

## 1. 用户模块

### 1.1 用户登录

- **请求地址**：`/users/login`
- **请求方式**：POST
- **入参**：

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1,
    "role": "用户",
    "name": "王用户",
    "avatar": "https://example.com/avatars/user1.jpg"
  }
}
```

### 1.2 用户注册

- **请求地址**：`/users/register`
- **请求方式**：POST
- **入参**：

```json
{
  "name": "张三",
  "email": "zhangsan@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": 7,
    "name": "张三",
    "email": "zhangsan@example.com",
    "role": "用户",
    "avatar": null
  }
}
```

### 1.3 修改用户信息

- **请求地址**：`/users/update`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "name": "张三修改",
  "avatar": "https://example.com/avatars/new.jpg"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "修改成功",
  "data": {
    "userId": 7,
    "name": "张三修改",
    "email": "zhangsan@example.com",
    "role": "用户",
    "avatar": "https://example.com/avatars/new.jpg"
  }
}
```

### 1.4 修改密码

- **请求地址**：`/users/change-password`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "oldPassword": "password123",
  "newPassword": "newpassword123",
  "confirmPassword": "newpassword123"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "密码修改成功",
  "data": null
}
```

### 1.5 获取用户信息

- **请求地址**：`/users/info`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：无
- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "userId": 7,
    "name": "张三",
    "email": "zhangsan@example.com",
    "role": "用户",
    "avatar": "https://example.com/avatars/user.jpg",
    "createdAt": "2023-04-10T14:30:45Z",
    "status": "启用"
  }
}
```

## 2. 餐厅模块

### 2.1 获取餐厅列表

- **请求地址**：`/restaurants`
- **请求方式**：GET
- **入参**：

```
?page=1&pageSize=10&status=运营&keyword=海鲜
```

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 25,
    "list": [
      {
        "id": 1,
        "name": "海鲜之家",
        "description": "提供各种新鲜海鲜料理，以粤菜为主。",
        "address": "北京市朝阳区建国路88号",
        "phone": "010-12345678",
        "photos": ["https://example.com/restaurants/seafood1.jpg"],
        "status": "运营",
        "businessHours": "周一至周五 11:00-22:00|周六至周日 10:00-23:00",
        "rating": 4.8
      },
      // ... 更多餐厅数据
    ]
  }
}
```

### 2.2 获取餐厅详情

- **请求地址**：`/restaurants/{restaurantId}`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}` (可选，用于判断是否收藏)
- **入参**：路径参数 restaurantId，查询参数 userId（可选）
- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "name": "海鲜之家",
    "description": "提供各种新鲜海鲜料理，以粤菜为主。我们坚持每日采购新鲜海产，确保顾客能享用到最新鲜的海鲜。",
    "address": "北京市朝阳区建国路88号",
    "phone": "010-12345678",
    "businessLicense": "BL123456789",
    "photos": ["https://example.com/restaurants/seafood1.jpg", "https://example.com/restaurants/seafood2.jpg"],
    "status": "运营",
    "businessHours": "周一至周五 11:00-22:00|周六至周日 10:00-23:00",
    "createdAt": "2023-01-15T10:30:00Z",
    "owner": {
      "id": 2,
      "name": "张经理"
    },
    "isFavorite": true,
    "tables": [
      {
        "id": 1,
        "type": "标准桌",
        "capacity": 4
      },
      {
        "id": 2,
        "type": "大桌",
        "capacity": 8
      },
      {
        "id": 3,
        "type": "VIP包间",
        "capacity": 12
      }
    ],
    "rating": 4.8,
    "reviewCount": 24
  }
}
```

## 3. 评价模块

### 3.1 获取餐厅评价列表

- **请求地址**：`/restaurants/{restaurantId}/reviews`
- **请求方式**：GET
- **入参**：

```
?page=1&pageSize=10&rating=5
```

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 24,
    "list": [
      {
        "id": 1,
        "userId": 4,
        "userName": "王用户",
        "userAvatar": "https://example.com/avatars/user1.jpg",
        "content": "海鲜非常新鲜，服务也很好！特别推荐他们家的清蒸石斑鱼和椒盐皮皮虾，下次一定再来。",
        "photos": ["https://example.com/reviews/seafood_review1.jpg", "https://example.com/reviews/seafood_review2.jpg"],
        "videos": ["https://example.com/reviews/seafood_video.mp4"],
        "rating": 5,
        "createdAt": "2023-03-15T18:30:00Z"
      },
      // ... 更多评价
    ]
  }
}
```

### 3.2 创建评价

- **请求地址**：`/reviews`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "restaurantId": 1,
  "content": "菜品很美味，环境很好，服务很周到，下次还会再来！",
  "photos": ["https://example.com/upload/review1.jpg", "https://example.com/upload/review2.jpg"],
  "videos": ["https://example.com/upload/review_video.mp4"],
  "rating": 5
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "评价成功",
  "data": {
    "id": 25,
    "restaurantId": 1,
    "userId": 7,
    "content": "菜品很美味，环境很好，服务很周到，下次还会再来！",
    "photos": ["https://example.com/upload/review1.jpg", "https://example.com/upload/review2.jpg"],
    "videos": ["https://example.com/upload/review_video.mp4"],
    "rating": 5,
    "createdAt": "2023-04-18T14:25:30Z"
  }
}
```

### 3.3 删除评价

- **请求地址**：`/reviews/{reviewId}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 reviewId
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

## 4. 预约模块

### 4.1 创建预约

- **请求地址**：`/reservations`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "restaurantId": 1,
  "tableId": 2,
  "reservationTime": "2023-04-20T18:30:00Z",
  "personCount": 6,
  "remarks": "希望靠窗"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "预约成功",
  "data": {
    "id": 10,
    "restaurantId": 1,
    "restaurantName": "海鲜之家",
    "tableId": 2,
    "tableType": "大桌",
    "reservationTime": "2023-04-20T18:30:00Z",
    "status": "待确认",
    "createdAt": "2023-04-18T14:30:00Z"
  }
}
```

### 4.2 获取历史预约

- **请求地址**：`/reservations`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&status=已确认,待确认
```

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 8,
    "list": [
      {
        "id": 10,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "tableId": 2,
        "tableType": "大桌",
        "reservationTime": "2023-04-20T18:30:00Z",
        "status": "待确认",
        "createdAt": "2023-04-18T14:30:00Z"
      },
      {
        "id": 5,
        "restaurantId": 2,
        "restaurantName": "京味小馆",
        "tableId": 4,
        "tableType": "标准桌",
        "reservationTime": "2023-04-15T19:00:00Z",
        "status": "已完成",
        "createdAt": "2023-04-10T12:30:00Z"
      },
      // ... 更多预约
    ]
  }
}
```

### 4.3 取消预约

- **请求地址**：`/reservations/{reservationId}/cancel`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "cancelReason": "临时有事"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "取消成功",
  "data": {
    "id": 10,
    "status": "已取消",
    "cancelReason": "临时有事",
    "updatedAt": "2023-04-18T16:30:00Z"
  }
}
```

## 5. 收藏模块

### 5.1 收藏餐厅

- **请求地址**：`/favorites`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "restaurantId": 3
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "收藏成功",
  "data": {
    "restaurantId": 3,
    "createdAt": "2023-04-18T16:45:00Z"
  }
}
```

### 5.2 取消收藏

- **请求地址**：`/favorites/{restaurantId}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 restaurantId
- **出参**：

```json
{
  "code": 200,
  "message": "取消收藏成功",
  "data": null
}
```

### 5.3 获取收藏列表

- **请求地址**：`/favorites`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10
```

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 3,
    "list": [
      {
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "description": "提供各种新鲜海鲜料理，以粤菜为主。",
        "address": "北京市朝阳区建国路88号",
        "photos": ["https://example.com/restaurants/seafood1.jpg"],
        "rating": 4.8,
        "createdAt": "2023-03-10T14:30:00Z"
      },
      // ... 更多收藏
    ]
  }
}
```

## 6. 错误码说明

| 错误码 | 说明 |
| --- | --- |
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权或token无效 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 500 | 服务器内部错误 |

## 7. 管理员用户管理模块

### 7.1 获取用户列表

- **请求地址**：`/admin/users`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&keyword=张三&role=2&status=1
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| keyword | String | 否 | 关键词(用户名或邮箱) |
| role | Integer | 否 | 角色筛选(0:管理员，1:餐厅经理，2:用户，3:服务员) |
| status | Integer | 否 | 状态筛选(0:禁用，1:启用) |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 25,
    "list": [
      {
        "userId": 1,
        "name": "张三",
        "email": "zhangsan@example.com",
        "role": "用户",
        "roleValue": 2,
        "status": "启用",
        "statusValue": 1,
        "avatar": "https://example.com/avatars/user1.jpg",
        "createdAt": "2023-04-10T14:30:45Z"
      }
    ]
  }
}
```

### 7.2 获取用户详情

- **请求地址**：`/admin/users/{userId}`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 userId
- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "userId": 1,
    "name": "张三",
    "email": "zhangsan@example.com",
    "role": "用户",
    "roleValue": 2,
    "status": "启用",
    "statusValue": 1,
    "avatar": "https://example.com/avatars/user1.jpg",
    "createdAt": "2023-04-10T14:30:45Z"
  }
}
```

### 7.3 添加用户

- **请求地址**：`/admin/users`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "name": "李四",
  "email": "lisi@example.com",
  "password": "password123",
  "roleValue": 2,
  "statusValue": 1,
  "avatar": "https://example.com/avatars/user2.jpg"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "userId": 2,
    "name": "李四",
    "email": "lisi@example.com",
    "role": "用户",
    "roleValue": 2,
    "status": "启用",
    "statusValue": 1,
    "avatar": "https://example.com/avatars/user2.jpg",
    "createdAt": "2023-04-18T14:30:45Z"
  }
}
```

### 7.4 更新用户信息

- **请求地址**：`/admin/users/{userId}`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "name": "李四修改",
  "email": "lisi_new@example.com",
  "roleValue": 2,
  "statusValue": 1,
  "avatar": "https://example.com/avatars/user2_new.jpg"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "userId": 2,
    "name": "李四修改",
    "email": "lisi_new@example.com",
    "role": "用户",
    "roleValue": 2,
    "status": "启用",
    "statusValue": 1,
    "avatar": "https://example.com/avatars/user2_new.jpg",
    "updatedAt": "2023-04-18T15:30:45Z"
  }
}
```

### 7.5 删除用户

- **请求地址**：`/admin/users/{userId}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 userId
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

### 7.6 更新用户状态

- **请求地址**：`/admin/users/{userId}/status`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?status=0
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| status | Integer | 是 | 状态值(0:禁用，1:启用) |

- **出参**：

```json
{
  "code": 200,
  "message": "更新状态成功",
  "data": {
    "userId": 2,
    "status": 0,
    "statusText": "禁用"
  }
}
```

### 7.7 更新用户角色

- **请求地址**：`/admin/users/{userId}/role`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?role=2
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| role | Integer | 是 | 角色值(0:管理员，1:餐厅经理，2:用户，3:服务员) |

- **出参**：

```json
{
  "code": 200,
  "message": "更新角色成功",
  "data": {
    "userId": 2,
    "role": 2,
    "roleText": "用户"
  }
}
```

### 7.8 重置用户密码

- **请求地址**：`/admin/users/{userId}/reset-password`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 userId
- **出参**：

```json
{
  "code": 200,
  "message": "重置密码成功，新密码为：123456",
  "data": null
}
```

## 8. 餐厅管理模块

### 8.1 获取餐厅列表（管理）

- **请求地址**：`/admin/restaurants`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&keyword=海鲜&status=3
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| keyword | String | 否 | 关键词(餐厅名称或地址) |
| status | Integer | 否 | 状态筛选(0:待审核，1:审核通过，2:关闭，3:运营) |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 25,
    "list": [
      {
        "id": 1,
        "name": "海鲜之家",
        "description": "提供各种新鲜海鲜料理，以粤菜为主。",
        "address": "北京市朝阳区建国路88号",
        "longitude": 116.46,
        "latitude": 39.92,
        "phone": "010-12345678",
        "businessLicense": "BL123456789",
        "photos": ["https://example.com/restaurants/seafood1.jpg"],
        "status": "运营",
        "businessHours": "周一至周五 11:00-22:00|周六至周日 10:00-23:00",
        "cuisine": "粤菜",
        "createdAt": "2023-04-10T14:30:45Z",
        "updatedAt": "2023-04-10T14:30:45Z",
        "ownerId": 2,
        "ownerName": "张经理"
      }
    ]
  }
}
```

### 8.2 获取餐厅详情（管理）

- **请求地址**：`/admin/restaurants/{id}`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 id
- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "name": "海鲜之家",
    "description": "提供各种新鲜海鲜料理，以粤菜为主。我们坚持每日采购新鲜海产，确保顾客能享用到最新鲜的海鲜。",
    "address": "北京市朝阳区建国路88号",
    "longitude": 116.46,
    "latitude": 39.92,
    "phone": "010-12345678",
    "businessLicense": "BL123456789",
    "photos": ["https://example.com/restaurants/seafood1.jpg", "https://example.com/restaurants/seafood2.jpg"],
    "status": "运营",
    "businessHours": "周一至周五 11:00-22:00|周六至周日 10:00-23:00",
    "cuisine": "粤菜",
    "createdAt": "2023-01-15T10:30:00Z",
    "updatedAt": "2023-04-10T14:30:45Z",
    "ownerId": 2,
    "ownerName": "张经理"
  }
}
```

### 8.3 添加餐厅

- **请求地址**：`/admin/restaurants`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "name": "京味小馆",
  "description": "正宗北京菜，老字号传承，特色烤鸭。",
  "address": "北京市西城区西单北大街110号",
  "longitude": 116.36,
  "latitude": 39.91,
  "phone": "010-87654321",
  "businessLicense": "BL987654321",
  "photos": ["https://example.com/restaurants/beijing1.jpg", "https://example.com/restaurants/beijing2.jpg"],
  "businessHours": "周一至周日 10:00-22:00",
  "cuisine": "京菜"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "id": 26,
    "name": "京味小馆",
    "description": "正宗北京菜，老字号传承，特色烤鸭。",
    "address": "北京市西城区西单北大街110号",
    "longitude": 116.36,
    "latitude": 39.91,
    "phone": "010-87654321",
    "businessLicense": "BL987654321",
    "photos": ["https://example.com/restaurants/beijing1.jpg", "https://example.com/restaurants/beijing2.jpg"],
    "status": "待审核",
    "businessHours": "周一至周日 10:00-22:00",
    "cuisine": "京菜",
    "createdAt": "2023-04-18T15:30:00Z",
    "updatedAt": "2023-04-18T15:30:00Z",
    "ownerId": 2,
    "ownerName": "张经理"
  }
}
```

### 8.4 更新餐厅信息

- **请求地址**：`/admin/restaurants/{id}`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "name": "京味小馆（翻新）",
  "description": "正宗北京菜，老字号传承，特色烤鸭和炸酱面。",
  "address": "北京市西城区西单北大街110号",
  "longitude": 116.36,
  "latitude": 39.91,
  "phone": "010-87654321",
  "businessLicense": "BL987654321",
  "photos": ["https://example.com/restaurants/beijing1.jpg", "https://example.com/restaurants/beijing2.jpg", "https://example.com/restaurants/beijing3.jpg"],
  "businessHours": "周一至周日 09:00-22:30",
  "cuisine": "京菜"
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": 26,
    "name": "京味小馆（翻新）",
    "description": "正宗北京菜，老字号传承，特色烤鸭和炸酱面。",
    "address": "北京市西城区西单北大街110号",
    "longitude": 116.36,
    "latitude": 39.91,
    "phone": "010-87654321",
    "businessLicense": "BL987654321",
    "photos": ["https://example.com/restaurants/beijing1.jpg", "https://example.com/restaurants/beijing2.jpg", "https://example.com/restaurants/beijing3.jpg"],
    "status": "待审核",
    "businessHours": "周一至周日 09:00-22:30",
    "cuisine": "京菜",
    "createdAt": "2023-04-18T15:30:00Z",
    "updatedAt": "2023-04-18T16:00:00Z",
    "ownerId": 2,
    "ownerName": "张经理"
  }
}
```

### 8.5 删除餐厅

- **请求地址**：`/admin/restaurants/{id}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 id
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

### 8.6 更新餐厅状态

- **请求地址**：`/admin/restaurants/{id}/status`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?status=3
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| status | Integer | 是 | 状态值(0:待审核，1:审核通过，2:关闭，3:运营) |

- **出参**：

```json
{
  "code": 200,
  "message": "更新状态成功",
  "data": {
    "id": 26,
    "status": 3,
    "statusText": "运营"
  }
}
```

### 8.7 获取我的餐厅列表（餐厅经理专用）

- **请求地址**：`/admin/restaurants/my-restaurants`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&keyword=京味&status=3
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| keyword | String | 否 | 关键词(餐厅名称或地址) |
| status | Integer | 否 | 状态筛选(0:待审核，1:审核通过，2:关闭，3:运营) |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 3,
    "list": [
      {
        "id": 26,
        "name": "京味小馆",
        "description": "正宗北京菜，老字号传承，特色烤鸭。",
        "address": "北京市西城区西单北大街110号",
        "longitude": 116.36,
        "latitude": 39.91,
        "phone": "010-87654321",
        "businessLicense": "BL987654321",
        "photos": ["https://example.com/restaurants/beijing1.jpg", "https://example.com/restaurants/beijing2.jpg"],
        "status": "运营",
        "businessHours": "周一至周日 10:00-22:00",
        "cuisine": "京菜",
        "createdAt": "2023-04-18T15:30:00Z",
        "updatedAt": "2023-04-18T16:30:00Z",
        "ownerId": 2,
        "ownerName": "张经理"
      }
    ]
  }
}
```

**说明**：餐厅管理接口仅供管理员(role=0)和餐厅经理(role=1)访问，其中：
- 管理员可以管理所有餐厅
- 餐厅经理只能管理自己创建的餐厅 

## 9. 餐桌管理模块

### 9.1 获取所有餐桌列表（管理员专用）

- **请求地址**：`/admin/tables`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&restaurantId=1
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| restaurantId | Integer | 否 | 餐厅ID，如果提供则只查询该餐厅的餐桌 |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 15,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "type": "标准桌",
        "capacity": 4,
        "createdAt": "2023-04-10T14:30:45Z",
        "updatedAt": "2023-04-10T14:30:45Z"
      },
      {
        "id": 2,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "type": "大桌",
        "capacity": 8,
        "createdAt": "2023-04-10T14:35:45Z",
        "updatedAt": "2023-04-10T14:35:45Z"
      }
    ]
  }
}
```

### 9.2 获取特定餐厅的餐桌列表（餐厅经理专用）

- **请求地址**：`/admin/tables/restaurant/{restaurantId}`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| restaurantId | Integer | 是 | 餐厅ID（路径参数） |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 5,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "type": "标准桌",
        "capacity": 4,
        "createdAt": "2023-04-10T14:30:45Z",
        "updatedAt": "2023-04-10T14:30:45Z"
      },
      {
        "id": 2,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "type": "大桌",
        "capacity": 8,
        "createdAt": "2023-04-10T14:35:45Z",
        "updatedAt": "2023-04-10T14:35:45Z"
      }
    ]
  }
}
```

### 9.3 获取餐桌详情

- **请求地址**：`/admin/tables/{id}`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 id
- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "restaurantId": 1,
    "type": "标准桌",
    "capacity": 4,
    "createdAt": "2023-04-10T14:30:45Z",
    "updatedAt": "2023-04-10T14:30:45Z"
  }
}
```

### 9.4 添加餐桌

- **请求地址**：`/admin/tables`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "restaurantId": 1,
  "type": "VIP包间",
  "capacity": 12
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "添加成功",
  "data": {
    "id": 3,
    "restaurantId": 1,
    "type": "VIP包间",
    "capacity": 12,
    "createdAt": "2023-04-18T15:30:00Z",
    "updatedAt": "2023-04-18T15:30:00Z"
  }
}
```

### 9.5 更新餐桌信息

- **请求地址**：`/admin/tables/{id}`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```json
{
  "type": "豪华VIP包间",
  "capacity": 16
}
```

- **出参**：

```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": 3,
    "restaurantId": 1,
    "type": "豪华VIP包间",
    "capacity": 16,
    "createdAt": "2023-04-18T15:30:00Z",
    "updatedAt": "2023-04-18T16:00:00Z"
  }
}
```

### 9.6 删除餐桌

- **请求地址**：`/admin/tables/{id}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 id
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

### 9.7 获取当前餐厅经理名下所有餐桌

- **请求地址**：`/admin/tables/my-tables`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 12,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "type": "标准桌",
        "capacity": 4,
        "createdAt": "2023-04-10T14:30:45Z",
        "updatedAt": "2023-04-10T14:30:45Z"
      },
      {
        "id": 5,
        "restaurantId": 2,
        "restaurantName": "京味小馆",
        "type": "VIP包间",
        "capacity": 10,
        "createdAt": "2023-04-12T10:30:45Z",
        "updatedAt": "2023-04-12T10:30:45Z"
      }
    ]
  }
}
```

**说明**：餐桌管理接口仅供管理员(role=0)和餐厅经理(role=1)访问，其中：
- 管理员可以管理所有餐桌
- 餐厅经理只能管理自己餐厅的餐桌

## 10. 预约管理模块

### 10.1 获取所有预约（管理员专用）

- **请求地址**：`/admin/reservations`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&status=1,2&restaurantId=1
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| status | String | 否 | 预约状态，多个状态用逗号分隔(0:已取消，1:待确认，2:已确认，3:已完成，4:已拒绝) |
| restaurantId | Integer | 否 | 餐厅ID，如果提供则只查询该餐厅的预约 |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 15,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "userId": 3,
        "tableId": 2,
        "tableType": "大桌",
        "reservationTime": "2023-05-20T18:30:00Z",
        "personCount": 6,
        "remarks": "靠窗位置",
        "status": "待确认",
        "statusValue": 1,
        "createdAt": "2023-05-15T10:30:45Z",
        "updatedAt": "2023-05-15T10:30:45Z"
      },
      {
        "id": 2,
        "restaurantId": 2,
        "restaurantName": "京味小馆",
        "userId": 5,
        "tableId": 4,
        "tableType": "标准桌",
        "reservationTime": "2023-05-21T19:00:00Z",
        "personCount": 4,
        "remarks": "希望提供婴儿椅",
        "status": "已确认",
        "statusValue": 2,
        "createdAt": "2023-05-15T11:22:45Z",
        "updatedAt": "2023-05-15T14:10:20Z"
      }
    ]
  }
}
```

### 10.2 获取餐厅经理名下餐厅的预约（餐厅经理专用）

- **请求地址**：`/admin/reservations/manager`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&status=1,2&restaurantId=1
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| status | String | 否 | 预约状态，多个状态用逗号分隔(0:已取消，1:待确认，2:已确认，3:已完成，4:已拒绝) |
| restaurantId | Integer | 否 | 餐厅ID，如果提供则只查询该餐厅的预约，该餐厅必须属于当前餐厅经理 |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 8,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "userId": 3,
        "tableId": 2,
        "tableType": "大桌",
        "reservationTime": "2023-05-20T18:30:00Z",
        "personCount": 6,
        "remarks": "靠窗位置",
        "status": "待确认",
        "statusValue": 1,
        "createdAt": "2023-05-15T10:30:45Z",
        "updatedAt": "2023-05-15T10:30:45Z"
      },
      {
        "id": 3,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "userId": 8,
        "tableId": 1,
        "tableType": "标准桌",
        "reservationTime": "2023-05-22T12:00:00Z",
        "personCount": 2,
        "remarks": "庆祝结婚纪念日",
        "status": "已确认",
        "statusValue": 2,
        "createdAt": "2023-05-15T16:45:22Z",
        "updatedAt": "2023-05-15T17:10:55Z"
      }
    ]
  }
}
```

**说明**：预约管理接口仅供管理员(role=0)和餐厅经理(role=1)访问，其中：
- 管理员可以查看所有预约
- 餐厅经理只能查看自己餐厅的预约

## 11. 员工管理模块

### 11.1 获取员工列表（餐厅经理专用）

- **请求地址**：`/admin/staff`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 8,
    "list": [
      {
        "id": 1,
        "managerId": 2,
        "userId": 3,
        "userName": "李服务员",
        "userEmail": "waiter@example.com",
        "status": 1,
        "createdAt": "2023-05-15T10:30:45Z",
        "updatedAt": "2023-05-15T10:30:45Z"
      }
    ]
  }
}
```

### 11.2 审核员工申请

- **请求地址**：`/admin/staff/{staffId}/status`
- **请求方式**：PUT
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?status=1
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| staffId | Integer | 是 | 员工ID（路径参数） |
| status | Integer | 是 | 状态值(0:待审核，1:审核通过) |

- **出参**：

```json
{
  "code": 200,
  "message": "更新状态成功",
  "data": null
}
```

### 11.3 删除员工

- **请求地址**：`/admin/staff/{staffId}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 staffId
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

**说明**：员工管理接口仅供餐厅经理(role=1)访问，餐厅经理只能管理自己名下的员工。所有接口都需要通过JWT token来验证身份和权限。

## 12. 评论管理模块

### 12.1 获取评论列表（管理员专用）

- **请求地址**：`/admin/reviews`
- **请求方式**：GET
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?page=1&pageSize=10&restaurantId=1&rating=5
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| restaurantId | Integer | 否 | 餐厅ID，如果提供则只查询该餐厅的评论 |
| rating | Integer | 否 | 评分筛选（1-5分） |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 24,
    "list": [
      {
        "id": 1,
        "restaurantId": 1,
        "restaurantName": "海鲜之家",
        "userId": 4,
        "userName": "王用户",
        "userAvatar": "https://example.com/avatars/user1.jpg",
        "content": "海鲜非常新鲜，服务也很好！特别推荐他们家的清蒸石斑鱼和椒盐皮皮虾，下次一定再来。",
        "photos": ["https://example.com/reviews/seafood_review1.jpg", "https://example.com/reviews/seafood_review2.jpg"],
        "videos": ["https://example.com/reviews/seafood_video.mp4"],
        "rating": 5,
        "createdAt": "2023-03-15T18:30:00Z"
      }
    ]
  }
}
```

### 12.2 删除评论（管理员专用）

- **请求地址**：`/admin/reviews/{reviewId}`
- **请求方式**：DELETE
- **请求头**：`Authorization: Bearer {token}`
- **入参**：路径参数 reviewId
- **出参**：

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

**说明**：评论管理接口仅供管理员(role=0)访问，用于管理系统内的所有评论。所有接口都需要通过JWT token来验证身份和权限。

## 13. 员工申请模块

### 13.1 获取餐厅经理列表

- **请求地址**：`/staff-apply/managers`
- **请求方式**：GET
- **入参**：

```
?page=1&pageSize=10&keyword=张经理
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| page | Integer | 否 | 页码，默认1 |
| pageSize | Integer | 否 | 每页数量，默认10 |
| keyword | String | 否 | 关键词(经理姓名或邮箱) |

- **出参**：

```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "total": 8,
    "list": [
      {
        "managerId": 2,
        "name": "张经理",
        "email": "manager@example.com",
        "avatar": "https://example.com/avatars/manager1.jpg",
        "createdAt": "2023-05-15T10:30:45Z"
      }
    ]
  }
}
```

### 13.2 提交员工申请

- **请求地址**：`/staff-apply`
- **请求方式**：POST
- **请求头**：`Authorization: Bearer {token}`
- **入参**：

```
?managerId=2
```

| 参数名 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| managerId | Integer | 是 | 经理ID |

- **出参**：

```json
{
  "code": 200,
  "message": "申请提交成功，等待经理审核",
  "data": {
    "id": 5,
    "userId": 7,
    "managerId": 2,
    "status": 0,
    "createdAt": "2023-05-20T15:30:45Z",
    "updatedAt": "2023-05-20T15:30:45Z"
  }
}
```

**说明**：员工申请接口用于普通用户(role=2)申请成为特定餐厅经理下的服务员。申请提交后初始状态为待审核(0)，需要餐厅经理通过`/admin/staff/{staffId}/status`接口审核通过后，用户角色才会变成服务员。