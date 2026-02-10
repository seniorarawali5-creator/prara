import React, { useContext } from 'react';
import { ActivityIndicator, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MaterialIcons } from '@expo/vector-icons';

import { AuthContext } from '../context/AuthContext';
import { SigninScreen } from '../screens/auth/SigninScreen';
import { SignupScreen } from '../screens/auth/SignupScreen';
import { HomeScreen } from '../screens/app/HomeScreen';
import { AddActivityScreen } from '../screens/app/AddActivityScreen';
import { AnalyticsScreen } from '../screens/app/AnalyticsScreen';
import { NotesScreen } from '../screens/app/NotesScreen';
import { AddNoteScreen } from '../screens/app/AddNoteScreen';
import { MemoriesScreen } from '../screens/app/MemoriesScreen';
import { ChatListScreen } from '../screens/app/ChatListScreen';
import { ChatScreen } from '../screens/app/ChatScreen';
import { FriendsScreen } from '../screens/app/FriendsScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

const AuthStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerShown: false,
      animationEnabled: true,
    }}
  >
    <Stack.Screen name="SignIn" component={SigninScreen} options={{ animationEnabled: false }} />
    <Stack.Screen name="Signup" component={SignupScreen} />
  </Stack.Navigator>
);

const HomeStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: { backgroundColor: '#5C6BC0' },
      headerTintColor: '#fff',
      headerTitleStyle: { fontWeight: 'bold' },
    }}
  >
    <Stack.Screen
      name="HomeScreen"
      component={HomeScreen}
      options={{ title: 'PRASHANT' }}
    />
    <Stack.Screen
      name="AddActivity"
      component={AddActivityScreen}
      options={{ title: 'Add Activity' }}
    />
    <Stack.Screen
      name="Analytics"
      component={AnalyticsScreen}
      options={{ title: 'Analytics' }}
    />
  </Stack.Navigator>
);

const NotesStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: { backgroundColor: '#5C6BC0' },
      headerTintColor: '#fff',
      headerTitleStyle: { fontWeight: 'bold' },
    }}
  >
    <Stack.Screen
      name="NotesScreen"
      component={NotesScreen}
      options={{ title: 'My Notes' }}
    />
    <Stack.Screen
      name="AddNote"
      component={AddNoteScreen}
      options={{ title: 'New Note' }}
    />
  </Stack.Navigator>
);

const MemoriesStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: { backgroundColor: '#5C6BC0' },
      headerTintColor: '#fff',
      headerTitleStyle: { fontWeight: 'bold' },
    }}
  >
    <Stack.Screen
      name="MemoriesScreen"
      component={MemoriesScreen}
      options={{ title: 'Memories' }}
    />
  </Stack.Navigator>
);

const ChatStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: { backgroundColor: '#5C6BC0' },
      headerTintColor: '#fff',
      headerTitleStyle: { fontWeight: 'bold' },
    }}
  >
    <Stack.Screen
      name="ChatList"
      component={ChatListScreen}
      options={{ title: 'Messages' }}
    />
    <Stack.Screen
      name="Chat"
      component={ChatScreen}
      options={({ route }) => ({ title: route.params?.username || 'Chat' })}
    />
  </Stack.Navigator>
);

const FriendsStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: { backgroundColor: '#5C6BC0' },
      headerTintColor: '#fff',
      headerTitleStyle: { fontWeight: 'bold' },
    }}
  >
    <Stack.Screen
      name="FriendsScreen"
      component={FriendsScreen}
      options={{ title: 'Friends' }}
    />
  </Stack.Navigator>
);

const AppTabs = () => (
  <Tab.Navigator
    screenOptions={({ route }) => ({
      headerShown: false,
      tabBarIcon: ({ focused, color, size }) => {
        let iconName;

        switch (route.name) {
          case 'Home':
            iconName = focused ? 'home' : 'home-outlined';
            break;
          case 'Notes':
            iconName = focused ? 'library-books' : 'library-books';
            break;
          case 'Memories':
            iconName = focused ? 'photo-library' : 'photo-library';
            break;
          case 'Chat':
            iconName = focused ? 'chat' : 'chat-outlined';
            break;
          case 'Friends':
            iconName = focused ? 'people' : 'people-outline';
            break;
          default:
            iconName = 'home';
        }

        return <MaterialIcons name={iconName} size={size} color={color} />;
      },
      tabBarActiveTintColor: '#5C6BC0',
      tabBarInactiveTintColor: '#999',
      tabBarStyle: {
        borderTopWidth: 1,
        borderTopColor: '#ddd',
      },
    })}
  >
    <Tab.Screen
      name="Home"
      component={HomeStack}
      options={{ title: 'Home' }}
    />
    <Tab.Screen
      name="Notes"
      component={NotesStack}
      options={{ title: 'Notes' }}
    />
    <Tab.Screen
      name="Memories"
      component={MemoriesStack}
      options={{ title: 'Memories' }}
    />
    <Tab.Screen
      name="Chat"
      component={ChatStack}
      options={{ title: 'Chat' }}
    />
    <Tab.Screen
      name="Friends"
      component={FriendsStack}
      options={{ title: 'Friends' }}
    />
  </Tab.Navigator>
);

export const Navigation = () => {
  const { state } = useContext(AuthContext);

  if (state.isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" color="#5C6BC0" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      {state.userToken == null ? <AuthStack /> : <AppTabs />}
    </NavigationContainer>
  );
};
