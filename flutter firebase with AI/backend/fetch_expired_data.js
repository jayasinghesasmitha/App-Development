const fs = require('fs');
const axios = require('axios');

async function fetchExpiredData() {
  try {
    // Fetch expired data from the server
    const response = await axios.get('http://localhost:3000/get-expired-data');
    const data = response.data.data;

    if (data.length === 0) {
      console.log('No expired data available.');
      return;
    }

    // Convert the data to CSV format
    const csvHeader = 'weather,rainAmount,movement,timestamp,latitude,longitude\n';
    const csvRows = data.map(row => {
      const latitude = row.location ? row.location.latitude : 0;
      const longitude = row.location ? row.location.longitude : 0;
      return `${row.weather},${row.rainAmount},${row.movement},${row.timestamp},${latitude},${longitude}`;
    }).join('\n');

    // Save the data to a CSV file in the ai-model folder
    fs.writeFileSync('../ai-model/weather_data.csv', csvHeader + csvRows);
    console.log('Expired data saved to weather_data.csv');
  } catch (error) {
    console.error('Error fetching expired data:', error);
  }
}

fetchExpiredData();