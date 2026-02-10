import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Alert,
  Picker,
} from 'react-native';
import { activitiesAPI } from '../api/client';

export const AddActivityScreen = ({ navigation }) => {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    subject: '',
    durationMinutes: '',
    activityType: 'study',
    category: '',
  });

  const handleAddActivity = async () => {
    if (!formData.title || !formData.durationMinutes) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }

    setLoading(true);
    try {
      const payload = {
        ...formData,
        durationMinutes: parseInt(formData.durationMinutes),
      };

      await activitiesAPI.addActivity(payload);
      Alert.alert('Success', 'Activity added successfully!');
      navigation.goBack();
    } catch (error) {
      Alert.alert('Error', error.response?.data?.message || 'Failed to add activity');
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Add Activity</Text>

        <Text style={styles.label}>Activity Title *</Text>
        <TextInput
          style={styles.input}
          placeholder="e.g., Math Chapter 5"
          value={formData.title}
          onChangeText={(text) => setFormData({ ...formData, title: text })}
          editable={!loading}
        />

        <Text style={styles.label}>Subject</Text>
        <TextInput
          style={styles.input}
          placeholder="e.g., Mathematics"
          value={formData.subject}
          onChangeText={(text) => setFormData({ ...formData, subject: text })}
          editable={!loading}
        />

        <Text style={styles.label}>Description</Text>
        <TextInput
          style={[styles.input, styles.textarea]}
          placeholder="What did you study?"
          value={formData.description}
          onChangeText={(text) => setFormData({ ...formData, description: text })}
          multiline
          numberOfLines={4}
          editable={!loading}
        />

        <Text style={styles.label}>Duration (minutes) *</Text>
        <TextInput
          style={styles.input}
          placeholder="30"
          value={formData.durationMinutes}
          onChangeText={(text) => setFormData({ ...formData, durationMinutes: text })}
          keyboardType="number-pad"
          editable={!loading}
        />

        <Text style={styles.label}>Activity Type</Text>
        <Picker
          selectedValue={formData.activityType}
          onValueChange={(value) => setFormData({ ...formData, activityType: value })}
          style={styles.picker}
          enabled={!loading}
        >
          <Picker.Item label="Study" value="study" />
          <Picker.Item label="Exercise" value="exercise" />
          <Picker.Item label="Project" value="project" />
          <Picker.Item label="Reading" value="reading" />
          <Picker.Item label="Practice" value="practice" />
        </Picker>

        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={handleAddActivity}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Add Activity</Text>
          )}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
    color: '#333',
  },
  input: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    fontSize: 14,
  },
  textarea: {
    textAlignVertical: 'top',
  },
  picker: {
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#5C6BC0',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
