import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:5000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Add token to requests
apiClient.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const authAPI = {
  signup: (data) => apiClient.post('/api/auth/signup', data),
  signin: (data) => apiClient.post('/api/auth/signin', data),
};

export const activitiesAPI = {
  addActivity: (data) => apiClient.post('/api/activities', data),
  getActivities: (params) => apiClient.get('/api/activities', { params }),
  updateActivity: (id, data) => apiClient.put(`/api/activities/${id}`, data),
  deleteActivity: (id) => apiClient.delete(`/api/activities/${id}`),
};

export const goalsAPI = {
  createGoal: (data) => apiClient.post('/api/goals', data),
  getGoals: (params) => apiClient.get('/api/goals', { params }),
  updateGoalProgress: (id, progress) => apiClient.put(`/api/goals/${id}/progress`, { progress }),
  updateGoalStatus: (id, status) => apiClient.put(`/api/goals/${id}/status`, { status }),
  deleteGoal: (id) => apiClient.delete(`/api/goals/${id}`),
};

export const notesAPI = {
  createNote: (data) => apiClient.post('/api/notes', data),
  getNotes: () => apiClient.get('/api/notes'),
  getSharedNotes: () => apiClient.get('/api/notes/shared'),
  shareNote: (id, friendId) => apiClient.post(`/api/notes/${id}/share`, { friendId }),
  updateNote: (id, data) => apiClient.put(`/api/notes/${id}`, data),
  deleteNote: (id) => apiClient.delete(`/api/notes/${id}`),
};

export const memoriesAPI = {
  addMemory: (formData) => apiClient.post('/api/memories', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }),
  getMemories: () => apiClient.get('/api/memories'),
  getFriendMemories: (friendId) => apiClient.get(`/api/memories/friend/${friendId}`),
  deleteMemory: (id) => apiClient.delete(`/api/memories/${id}`),
};

export const messagesAPI = {
  sendMessage: (data) => apiClient.post('/api/messages', data),
  getConversation: (userId) => apiClient.get(`/api/messages/conversation/${userId}`),
  getConversations: () => apiClient.get('/api/messages'),
  getUnreadCount: () => apiClient.get('/api/messages/unread/count'),
  deleteMessage: (id) => apiClient.delete(`/api/messages/${id}`),
};

export const usersAPI = {
  getUserProfile: (userId) => apiClient.get(`/api/users/profile/${userId}`),
  searchUsers: (query) => apiClient.get('/api/users/search', { params: { query } }),
  sendFriendRequest: (userId) => apiClient.post(`/api/users/${userId}/friend-request`),
  acceptFriendRequest: (requestId) => apiClient.put(`/api/users/${requestId}/accept`),
  getFriendsList: () => apiClient.get('/api/users/list'),
  getPendingRequests: () => apiClient.get('/api/users/requests/pending'),
  removeFriend: (friendId) => apiClient.delete(`/api/users/${friendId}`),
};

export const analyticsAPI = {
  getWeeklyAnalytics: (params) => apiClient.get('/api/analytics/weekly', { params }),
  getMonthlyAnalytics: (params) => apiClient.get('/api/analytics/monthly', { params }),
  getSubjectAnalytics: () => apiClient.get('/api/analytics/subject'),
  getGroupComparison: () => apiClient.get('/api/analytics/group/comparison'),
};

export default apiClient;
