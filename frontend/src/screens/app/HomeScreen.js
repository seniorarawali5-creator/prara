import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { activitiesAPI, analyticsAPI } from '../api/client';
import { MaterialIcons } from '@expo/vector-icons';

export const HomeScreen = ({ navigation }) => {
  const [activities, setActivities] = useState([]);
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
    const unsubscribe = navigation.addListener('focus', loadData);
    return unsubscribe;
  }, [navigation]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [activitiesRes, analyticsRes] = await Promise.all([
        activitiesAPI.getActivities({ startDate: new Date().toISOString().split('T')[0] }),
        analyticsAPI.getWeeklyAnalytics(),
      ]);
      
      setActivities(activitiesRes.data.activities);
      setAnalytics(analyticsRes.data);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderActivityCard = ({ item }) => (
    <View style={styles.activityCard}>
      <View style={styles.cardHeader}>
        <Text style={styles.activityTitle}>{item.title}</Text>
        <MaterialIcons name="more-vert" size={20} color="#666" />
      </View>
      <Text style={styles.activitySubject}>{item.subject}</Text>
      <Text style={styles.activityText}>{item.description}</Text>
      <View style={styles.cardFooter}>
        <Text style={styles.duration}>⏱️ {item.duration_minutes} min</Text>
        <Text style={styles.category}>{item.activity_type}</Text>
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
    <ScrollView style={styles.container}>
      {/* Stats Section */}
      <View style={styles.statsContainer}>
        <Text style={styles.sectionTitle}>This Week</Text>
        <View style={styles.statsRow}>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{analytics?.totalStudyHours?.toFixed(1) || 0}</Text>
            <Text style={styles.statLabel}>Hours</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{activities.length}</Text>
            <Text style={styles.statLabel}>Activities</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{analytics?.goalsProgress?.completed_goals || 0}</Text>
            <Text style={styles.statLabel}>Goals Done</Text>
          </View>
        </View>
      </View>

      {/* Quick Actions */}
      <View style={styles.quickActions}>
        <TouchableOpacity style={styles.actionBtn} onPress={() => navigation.navigate('AddActivity')}>
          <MaterialIcons name="add-circle" size={30} color="#fff" />
          <Text style={styles.actionText}>Add Activity</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionBtn} onPress={() => navigation.navigate('Analytics')}>
          <MaterialIcons name="bar-chart" size={30} color="#fff" />
          <Text style={styles.actionText}>Analytics</Text>
        </TouchableOpacity>
      </View>

      {/* Today's Activities */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Today's Activities</Text>
        {activities.length > 0 ? (
          <FlatList
            data={activities}
            renderItem={renderActivityCard}
            keyExtractor={(item) => item.id.toString()}
            scrollEnabled={false}
          />
        ) : (
          <Text style={styles.emptyText}>No activities yet. Add one to get started!</Text>
        )}
      </View>
    </ScrollView>
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
  statsContainer: {
    backgroundColor: '#fff',
    padding: 16,
    marginBottom: 10,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  statCard: {
    backgroundColor: '#f0f0f0',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    width: '30%',
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#5C6BC0',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 10,
    marginBottom: 15,
  },
  actionBtn: {
    backgroundColor: '#5C6BC0',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    width: '48%',
  },
  actionText: {
    color: '#fff',
    marginTop: 5,
    fontSize: 12,
    fontWeight: '500',
  },
  section: {
    paddingHorizontal: 16,
    marginBottom: 20,
  },
  activityCard: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
    borderLeftWidth: 4,
    borderLeftColor: '#5C6BC0',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  activityTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    flex: 1,
  },
  activitySubject: {
    fontSize: 12,
    color: '#5C6BC0',
    fontWeight: '500',
    marginBottom: 5,
  },
  activityText: {
    fontSize: 13,
    color: '#666',
    marginBottom: 10,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  duration: {
    fontSize: 12,
    color: '#999',
  },
  category: {
    backgroundColor: '#f0f0f0',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
    fontSize: 12,
    color: '#666',
  },
  emptyText: {
    textAlign: 'center',
    color: '#999',
    fontSize: 14,
    marginTop: 20,
  },
});
