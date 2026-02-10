import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  Image,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { memoriesAPI } from '../api/client';
import { MaterialIcons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';

export const MemoriesScreen = ({ navigation }) => {
  const [memories, setMemories] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadMemories();
    const unsubscribe = navigation.addListener('focus', loadMemories);
    return unsubscribe;
  }, [navigation]);

  const loadMemories = async () => {
    try {
      setLoading(true);
      const response = await memoriesAPI.getMemories();
      setMemories(response.data.memories);
    } catch (error) {
      console.error('Error loading memories:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddMemory = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission denied', 'Camera roll access is required to upload memories');
      return;
    }

    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
    });

    if (!result.canceled) {
      const formData = new FormData();
      formData.append('image', {
        uri: result.assets[0].uri,
        type: 'image/jpeg',
        name: 'memory.jpg',
      });
      formData.append('title', 'Memory');
      formData.append('description', '');

      uploadMemory(formData);
    }
  };

  const uploadMemory = async (formData) => {
    try {
      await memoriesAPI.addMemory(formData);
      loadMemories();
      Alert.alert('Success', 'Memory added successfully!');
    } catch (error) {
      Alert.alert('Error', 'Failed to upload memory');
    }
  };

  const handleDeleteMemory = async (id) => {
    Alert.alert('Delete Memory', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        onPress: async () => {
          try {
            await memoriesAPI.deleteMemory(id);
            setMemories(memories.filter((m) => m.id !== id));
          } catch (error) {
            Alert.alert('Error', 'Failed to delete memory');
          }
        },
        style: 'destructive',
      },
    ]);
  };

  const renderMemoryCard = ({ item }) => (
    <View style={styles.memoryCard}>
      <Image
        source={{ uri: item.image_url }}
        style={styles.memoryImage}
        defaultSource={require('../assets/placeholder.png')}
      />
      <TouchableOpacity
        style={styles.deleteButton}
        onPress={() => handleDeleteMemory(item.id)}
      >
        <MaterialIcons name="delete" size={20} color="#fff" />
      </TouchableOpacity>
      <View style={styles.memoryInfo}>
        <Text style={styles.memoryTitle}>{item.title || 'Memory'}</Text>
        <Text style={styles.memoryDate}>
          {new Date(item.created_at).toLocaleDateString()}
        </Text>
      </View>
    </View>
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
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Memories</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={handleAddMemory}
        >
          <MaterialIcons name="add-a-photo" size={24} color="#fff" />
        </TouchableOpacity>
      </View>

      {memories.length > 0 ? (
        <FlatList
          data={memories}
          renderItem={renderMemoryCard}
          keyExtractor={(item) => item.id.toString()}
          numColumns={2}
          columnWrapperStyle={styles.row}
          contentContainerStyle={styles.content}
        />
      ) : (
        <View style={styles.emptyContainer}>
          <MaterialIcons name="image" size={48} color="#ddd" />
          <Text style={styles.emptyText}>No memories yet</Text>
          <TouchableOpacity
            style={styles.createButton}
            onPress={handleAddMemory}
          >
            <Text style={styles.createButtonText}>Add Your First Memory</Text>
          </TouchableOpacity>
        </View>
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
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
    backgroundColor: '#fff',
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  addButton: {
    backgroundColor: '#5C6BC0',
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    padding: 8,
  },
  row: {
    justifyContent: 'space-around',
  },
  memoryCard: {
    width: '48%',
    backgroundColor: '#fff',
    borderRadius: 10,
    overflow: 'hidden',
    marginBottom: 16,
    elevation: 3,
  },
  memoryImage: {
    width: '100%',
    height: 150,
    backgroundColor: '#f0f0f0',
  },
  deleteButton: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: 'rgba(0,0,0,0.6)',
    borderRadius: 20,
    width: 36,
    height: 36,
    justifyContent: 'center',
    alignItems: 'center',
  },
  memoryInfo: {
    padding: 10,
  },
  memoryTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  memoryDate: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
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
  createButton: {
    marginTop: 20,
    backgroundColor: '#5C6BC0',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
  },
  createButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
});
