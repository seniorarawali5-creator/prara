import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
  Dimensions,
  TouchableOpacity,
} from 'react-native';
import { analyticsAPI } from '../api/client';
import { LineChart, BarChart } from 'react-native-chart-kit';
import { MaterialIcons } from '@expo/vector-icons';

const screenWidth = Dimensions.get('window').width;

export const AnalyticsScreen = ({ navigation }) => {
  const [weeklyData, setWeeklyData] = useState(null);
  const [monthlyData, setMonthlyData] = useState(null);
  const [subjectData, setSubjectData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [chartType, setChartType] = useState('weekly');

  useEffect(() => {
    loadAnalytics();
    const unsubscribe = navigation.addListener('focus', loadAnalytics);
    return unsubscribe;
  }, [navigation]);

  const loadAnalytics = async () => {
    try {
      setLoading(true);
      const [weeklyRes, monthlyRes, subjectRes] = await Promise.all([
        analyticsAPI.getWeeklyAnalytics(),
        analyticsAPI.getMonthlyAnalytics(),
        analyticsAPI.getSubjectAnalytics(),
      ]);

      setWeeklyData(weeklyRes.data);
      setMonthlyData(monthlyRes.data);
      setSubjectData(subjectRes.data);
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color="#5C6BC0" />
      </View>
    );
  }

  const chartData = {
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    datasets: [
      {
        data: [2, 3, 4, 3.5, 5, 4, 3.5],
      },
    ],
  };

  return (
    <ScrollView style={styles.container}>
      {/* Toggle Buttons */}
      <View style={styles.toggleContainer}>
        <TouchableOpacity
          style={[styles.toggleBtn, chartType === 'weekly' && styles.toggleBtnActive]}
          onPress={() => setChartType('weekly')}
        >
          <Text style={[styles.toggleText, chartType === 'weekly' && styles.toggleTextActive]}>Weekly</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.toggleBtn, chartType === 'monthly' && styles.toggleBtnActive]}
          onPress={() => setChartType('monthly')}
        >
          <Text style={[styles.toggleText, chartType === 'monthly' && styles.toggleTextActive]}>Monthly</Text>
        </TouchableOpacity>
      </View>

      {/* Study Hours Chart */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Study Hours Trend</Text>
        <LineChart
          data={chartData}
          width={screenWidth - 40}
          height={250}
          chartConfig={{
            backgroundColor: '#fff',
            backgroundGradientFrom: '#fff',
            backgroundGradientTo: '#fff',
            color: () => '#5C6BC0',
            labelColor: () => '#666',
            decimalPlaces: 1,
          }}
          style={{ borderRadius: 10 }}
        />
      </View>

      {/* Summary Stats */}
      <View style={styles.statsSection}>
        <View style={styles.statItem}>
          <MaterialIcons name="timer" size={24} color="#5C6BC0" />
          <Text style={styles.statValue}>{weeklyData?.totalStudyHours?.toFixed(1) || 0}</Text>
          <Text style={styles.statLabel}>Total Hours</Text>
        </View>
        <View style={styles.statItem}>
          <MaterialIcons name="task-alt" size={24} color="#4CAF50" />
          <Text style={styles.statValue}>{weeklyData?.goalsProgress?.completed_goals || 0}</Text>
          <Text style={styles.statLabel}>Goals Done</Text>
        </View>
      </View>

      {/* Subject-wise Analysis */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Subject-wise Study</Text>
        {subjectData?.subjectAnalytics?.map((subject, index) => (
          <View key={index} style={styles.subjectItem}>
            <View style={styles.subjectInfo}>
              <Text style={styles.subjectName}>{subject.subject}</Text>
              <Text style={styles.subjectTime}>{(subject.total_minutes / 60).toFixed(1)}h</Text>
            </View>
            <View style={styles.progressBar}>
              <View
                style={[
                  styles.progressFill,
                  { width: `${Math.min((subject.total_minutes / 300) * 100, 100)}%` },
                ]}
              />
            </View>
          </View>
        ))}
      </View>

      {/* Goals Progress */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Goals Progress</Text>
        <View style={styles.goalProgressContainer}>
          <View style={styles.goalCard}>
            <Text style={styles.goalLabel}>Goals Completed</Text>
            <Text style={styles.goalValue}>{weeklyData?.goalsProgress?.completed_goals || 0}</Text>
            <Text style={styles.goalTotal}>/ {weeklyData?.goalsProgress?.total_goals || 0}</Text>
          </View>
        </View>
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
  toggleContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingTop: 16,
    marginBottom: 16,
  },
  toggleBtn: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
    marginHorizontal: 4,
    backgroundColor: '#fff',
    alignItems: 'center',
  },
  toggleBtnActive: {
    backgroundColor: '#5C6BC0',
  },
  toggleText: {
    color: '#666',
    fontWeight: '600',
  },
  toggleTextActive: {
    color: '#fff',
  },
  section: {
    backgroundColor: '#fff',
    marginHorizontal: 16,
    marginBottom: 16,
    padding: 16,
    borderRadius: 10,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  statsSection: {
    flexDirection: 'row',
    marginHorizontal: 16,
    marginBottom: 16,
  },
  statItem: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 10,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  statValue: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#5C6BC0',
    marginVertical: 8,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
  },
  subjectItem: {
    marginBottom: 15,
  },
  subjectInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  subjectName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  subjectTime: {
    fontSize: 14,
    color: '#5C6BC0',
    fontWeight: '500',
  },
  progressBar: {
    height: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#5C6BC0',
  },
  goalProgressContainer: {
    alignItems: 'center',
  },
  goalCard: {
    alignItems: 'center',
    paddingVertical: 20,
  },
  goalLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
  },
  goalValue: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#5C6BC0',
  },
  goalTotal: {
    fontSize: 12,
    color: '#999',
    marginTop: 5,
  },
});
