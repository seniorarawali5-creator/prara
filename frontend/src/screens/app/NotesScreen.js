import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  TextInput,
} from 'react-native';
import { notesAPI } from '../api/client';
import { MaterialIcons } from '@expo/vector-icons';

export const NotesScreen = ({ navigation }) => {
  const [notes, setNotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadNotes();
    const unsubscribe = navigation.addListener('focus', loadNotes);
    return unsubscribe;
  }, [navigation]);

  const loadNotes = async () => {
    try {
      setLoading(true);
      const response = await notesAPI.getNotes();
      setNotes(response.data.notes);
    } catch (error) {
      console.error('Error loading notes:', error);
      Alert.alert('Error', 'Failed to load notes');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteNote = async (id) => {
    Alert.alert('Delete Note', 'Are you sure you want to delete this note?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        onPress: async () => {
          try {
            await notesAPI.deleteNote(id);
            setNotes(notes.filter((note) => note.id !== id));
          } catch (error) {
            Alert.alert('Error', 'Failed to delete note');
          }
        },
        style: 'destructive',
      },
    ]);
  };

  const filteredNotes = notes.filter((note) =>
    note.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const renderNoteCard = ({ item }) => (
    <TouchableOpacity
      style={styles.noteCard}
      onPress={() => navigation.navigate('NoteDetail', { noteId: item.id })}
    >
      <View style={styles.cardHeader}>
        <View style={styles.cardTitle}>
          <Text style={styles.noteTitle} numberOfLines={1}>
            {item.title}
          </Text>
          {item.subject && <Text style={styles.subject}>{item.subject}</Text>}
        </View>
        <TouchableOpacity onPress={() => handleDeleteNote(item.id)}>
          <MaterialIcons name="delete" size={20} color="#999" />
        </TouchableOpacity>
      </View>
      <Text style={styles.cardContent} numberOfLines={2}>
        {item.content}
      </Text>
      <Text style={styles.cardDate}>
        {new Date(item.created_at).toLocaleDateString()}
      </Text>
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
      <View style={styles.header}>
        <TextInput
          style={styles.searchBox}
          placeholder="Search notes..."
          value={searchQuery}
          onChangeText={setSearchQuery}
          placeholderTextColor="#999"
        />
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => navigation.navigate('AddNote')}
        >
          <MaterialIcons name="add" size={24} color="#fff" />
        </TouchableOpacity>
      </View>

      {filteredNotes.length > 0 ? (
        <FlatList
          data={filteredNotes}
          renderItem={renderNoteCard}
          keyExtractor={(item) => item.id.toString()}
          contentContainerStyle={styles.content}
        />
      ) : (
        <View style={styles.emptyContainer}>
          <MaterialIcons name="note" size={48} color="#ddd" />
          <Text style={styles.emptyText}>No notes yet</Text>
          <TouchableOpacity
            style={styles.createButton}
            onPress={() => navigation.navigate('AddNote')}
          >
            <Text style={styles.createButtonText}>Create Your First Note</Text>
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
    padding: 16,
    backgroundColor: '#fff',
    alignItems: 'center',
  },
  searchBox: {
    flex: 1,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginRight: 10,
    fontSize: 14,
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
    padding: 16,
  },
  noteCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    elevation: 3,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  cardTitle: {
    flex: 1,
  },
  noteTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  subject: {
    fontSize: 12,
    color: '#5C6BC0',
    marginTop: 4,
  },
  cardContent: {
    fontSize: 13,
    color: '#666',
    marginBottom: 10,
    lineHeight: 18,
  },
  cardDate: {
    fontSize: 12,
    color: '#999',
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
