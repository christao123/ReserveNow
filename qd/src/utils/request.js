import axios from "axios";
import { ElMessage } from "element-plus";

const service = axios.create({
  baseURL: "http://localhost:8080",
  timeout: 5000,
});

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    // 从cookie中获取token
    const token = document.cookie.replace(/(?:(?:^|.*;\s*)token\s*=\s*([^;]*).*$)|^.*$/, "$1");
    
    console.log(token);
    // 如果有token则添加到请求头
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
service.interceptors.response.use(
  (response) => {
    const res = response.data;
    if (res.code !== 200) {
      ElMessage.error(res.message || "错误");
      return Promise.reject(new Error(res.message || "错误"));
    }
    return res;
  },
  (error) => {
    ElMessage.error(error.message || "请求错误");
    return Promise.reject(error);
  }
);

export default service;
