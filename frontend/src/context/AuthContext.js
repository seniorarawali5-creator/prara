import React, { createContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { authAPI } from '../api/client';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = React.useReducer(
    (prevState, action) => {
      switch (action.type) {
        case 'RESTORE_TOKEN':
          return {
            ...prevState,
            userToken: action.token,
            isLoading: false,
            user: action.user,
          };
        case 'SIGN_IN':
          return {
            ...prevState,
            isSignout: false,
            userToken: action.token,
            user: action.user,
          };
        case 'SIGN_OUT':
          return {
            ...prevState,
            isSignout: true,
            userToken: null,
            user: null,
          };
        case 'SIGN_UP':
          return {
            ...prevState,
            isSignout: false,
            userToken: action.token,
            user: action.user,
          };
      }
    },
    {
      isLoading: true,
      isSignout: false,
      userToken: null,
      user: null,
    }
  );

  useEffect(() => {
    const bootstrapAsync = async () => {
      let userToken;
      try {
        userToken = await AsyncStorage.getItem('authToken');
      } catch (e) {
        // Restoring token failed
      }

      dispatch({ type: 'RESTORE_TOKEN', token: userToken, user: null });
    };

    bootstrapAsync();
  }, []);

  const authContext = {
    state,
    signin: async (email, password) => {
      try {
        const response = await authAPI.signin({ email, password });
        const { token, user } = response.data;
        
        await AsyncStorage.setItem('authToken', token);
        await AsyncStorage.setItem('user', JSON.stringify(user));
        
        dispatch({ type: 'SIGN_IN', token, user });
        return { success: true };
      } catch (error) {
        return {
          success: false,
          message: error.response?.data?.message || 'Sign in failed'
        };
      }
    },
    signup: async (userData) => {
      try {
        const response = await authAPI.signup(userData);
        const { token, user } = response.data;
        
        await AsyncStorage.setItem('authToken', token);
        await AsyncStorage.setItem('user', JSON.stringify(user));
        
        dispatch({ type: 'SIGN_UP', token, user });
        return { success: true };
      } catch (error) {
        return {
          success: false,
          message: error.response?.data?.message || 'Sign up failed'
        };
      }
    },
    signout: async () => {
      await AsyncStorage.removeItem('authToken');
      await AsyncStorage.removeItem('user');
      dispatch({ type: 'SIGN_OUT' });
    },
  };

  return (
    <AuthContext.Provider value={authContext}>
      {children}
    </AuthContext.Provider>
  );
};
