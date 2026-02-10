import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  TextInput,
  Alert,
  ScrollView,
} from 'react-native';
import { usersAPI } from '../api/client';
import { MaterialIcons } from '@expo/vector-icons';

export const FriendsScreen = ({ navigation }) => {
  const [friends, setFriends] = useState([]);
  const [pendingRequests, setPendingRequests] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('friends');

  useEffect(() => {
    loadData();
    const unsubscribe = navigation.addListener('focus', loadData);
    return unsubscribe;
  }, [navigation]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [friendsRes, requestsRes] = await Promise.all([
        usersAPI.getFriendsList(),
        usersAPI.getPendingRequests(),
      ]);
      setFriends(friendsRes.data.friends);
      setPendingRequests(requestsRes.data.pendingRequests);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (query) => {
    setSearchQuery(query);
    if (query.length < 2) {
      setSearchResults([]);
      return;
    }

    try {
      const response = await usersAPI.searchUsers(query);
      setSearchResults(response.data.users);
    } catch (error) {
      console.error('Error searching users:', error);
    }
  };

  const handleAddFriend = async (userId) => {
    try {
      await usersAPI.sendFriendRequest(userId);
      Alert.alert('Success', 'Friend request sent!');
      setSearchQuery('');
      setSearchResults([]);
    } catch (error) {
      Alert.alert('Error', error.response?.data?.message || 'Failed to send friend request');
    }
  };

  const handleAcceptRequest = async (requestId) => {
    try {
      await usersAPI.acceptFriendRequest(requestId);
      loadData();
      Alert.alert('Success', 'Friend request accepted!');
    } catch (error) {
      Alert.alert('Error', 'Failed to accept friend request');
    }
  };

  const handleRemoveFriend = async (friendId) => {
    Alert.alert('Remove Friend', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Remove',
        onPress: async () => {
          try {
            await usersAPI.removeFriend(friendId);
            setFriends(friends.filter((f) => f.id !== friendId));
          } catch (error) {
            Alert.alert('Error', 'Failed to remove friend');
          }
        },
        style: 'destructive',
      },
    ]);
  };

  const renderUser = ({ item, onPress, button }) => (
    <View style={styles.userCard}>
      <View style={styles.userInfo}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>
            {(item.first_name || item.username)[0].toUpperCase()}
          </Text>
        </View>
        <View style={styles.details}>
          <Text style={styles.userName}>{item.first_name || item.username}</Text>
          <Text style={styles.userHandle}>@{item.username}</Text>
        </View>
      </View>
      {button && (
        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => onPress(item.id || item.request_id)}
        >
          <Text style={styles.buttonText}>{button}</Text>
        </TouchableOpacity>
      )}
    </View>
  );

  const renderFriendAction = ({ item }) => (
    <TouchableOpacity
      style={styles.userCard}
      onPress={() =>
        navigation.navigate('Chat', {
          userId: item.id,
          username: item.first_name || item.username,
        })
      }
    >
      <View style={styles.userInfo}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>
            {(item.first_name || item.username)[0].toUpperCase()}
          </Text>
        </View>
        <View style={styles.details}>
          <Text style={styles.userName}>{item.first_name || item.username}</Text>
          <Text style={styles.userHandle}>@{item.username}</Text>
        </View>
      </View>
      <TouchableOpacity
        style={styles.deleteButton}
        onPress={() => handleRemoveFriend(item.id)}
      >
        <MaterialIcons name="delete" size={20} color="#FF6B6B" />
      </TouchableOpacity>
    </TouchableOpacity>
  );

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#5C6BC0" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.searchBox}
        placeholder="Search users..."
        value={searchQuery}
        onChangeText={handleSearch}
        placeholderTextColor="#999"
      />

      {searchResults.length > 0 && searchQuery ? (
        <ScrollView style={styles.content}>
          <Text style={styles.sectionTitle}>Search Results</Text>
          {searchResults.map((user) => (
            <View key={user.id} style={styles.userCard}>
              <View style={styles.userInfo}>
                <View style={styles.avatar}>
                  <Text style={styles.avatarText}>
                    {(user.first_name || user.username)[0].toUpperCase()}
                  </Text>
                </View>
                <View style={styles.details}>
                  <Text style={styles.userName}>{user.first_name || user.username}</Text>
                  <Text style={styles.userHandle}>@{user.username}</Text>
                </View>
              </View>
              <TouchableOpacity
                style={styles.actionButton}
                onPress={() => handleAddFriend(user.id)}
              >
                <Text style={styles.buttonText}>Add</Text>
              </TouchableOpacity>
            </View>
          ))}
        </ScrollView>
      ) : (
        <>
          <View style={styles.tabs}>
            <TouchableOpacity
              style={[styles.tab, activeTab === 'friends' && styles.tabActive]}
              onPress={() => setActiveTab('friends')}
            >
              <Text
                style={[
                  styles.tabText,
                  activeTab === 'friends' && styles.tabTextActive,
                ]}
              >
                Friends ({friends.length})
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.tab, activeTab === 'requests' && styles.tabActive]}
              onPress={() => setActiveTab('requests')}
            >
              <Text
                style={[
                  styles.tabText,
                  activeTab === 'requests' && styles.tabTextActive,
                ]}
              >
                Requests ({pendingRequests.length})
              </Text>
            </TouchableOpacity>
          </View>

          {activeTab === 'friends' ? (
            friends.length > 0 ? (
              <FlatList
                data={friends}
                renderItem={renderFriendAction}
                keyExtractor={(item) => item.id.toString()}
              />
            ) : (
              <View style={styles.emptyContainer}>
                <MaterialIcons name="person-add" size={48} color="#ddd" />
                <Text style={styles.emptyText}>No friends yet</Text>
              </View>
            )
          ) : pendingRequests.length > 0 ? (
            <FlatList
              data={pendingRequests}
              renderItem={({ item }) => (
                <View style={styles.userCard}>
                  <View style={styles.userInfo}>
                    <View style={styles.avatar}>
                      <Text style={styles.avatarText}>
                        {(item.first_name || item.username)[0].toUpperCase()}
                      </Text>
                    </View>
                    <View style={styles.details}>
                      <Text style={styles.userName}>
                        {item.first_name || item.username}
                      </Text>
                      <Text style={styles.userHandle}>@{item.username}</Text>
                    </View>
                  </View>
                  <TouchableOpacity
                    style={styles.acceptButton}
                    onPress={() => handleAcceptRequest(item.request_id)}
                  >
                    <Text style={styles.acceptButtonText}>Accept</Text>
                  </TouchableOpacity>
                </View>
              )}
              keyExtractor={(item) => item.request_id.toString()}
            />
          ) : (
            <View style={styles.emptyContainer}>
              <MaterialIcons name="mail" size={48} color="#ddd" />
              <Text style={styles.emptyText}>No pending requests</Text>
            </View>
          )}
        </>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchBox: {
    margin: 16,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 14,
  },
  content: {
    flex: 1,
  },
  tabs: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#ddd',
  },
  tab: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
    borderBottomWidth: 3,
    borderBottomColor: 'transparent',
  },
  tabActive: {
    borderBottomColor: '#5C6BC0',
  },
  tabText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '600',
  },
  tabTextActive: {
    color: '#5C6BC0',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 8,
    color: '#333',
  },
  userCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  userInfo: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#5C6BC0',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  avatarText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  details: {
    flex: 1,
  },
  userName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  userHandle: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
  },
  actionButton: {
    backgroundColor: '#5C6BC0',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 12,
  },
  acceptButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
  },
  acceptButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 12,
  },
  deleteButton: {
    padding: 8,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#999',
    marginTop: 10,
  },
});
