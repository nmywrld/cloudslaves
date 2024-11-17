import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 1000 }, // Ramp-up to 1000 users in the next 2 minutes
    { duration: '1m', target: 2000 }, // Ramp-up to 2000 users in the next 2 minutes
    { duration: '5m', target: 2000 }, // Hold at 2000 users for 5 minutes
    { duration: '1m', target: 0 },    // Ramp-down to 0 users in 2 minutes
  ],
};

export default function () {
  const headers = { 'x-k6-test': 'k6-test-header' };
  // const headers = { 'x-k6-test': 'wrong-header' };
  const res = http.get('http://frontend-app-lb-1870491001.us-east-1.elb.amazonaws.com/home', { headers });

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1); // Pause for 1 second between requests to simulate real user behavior
}

// k6 run ui_loadtest.js