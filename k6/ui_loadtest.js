import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 500 },  // Ramp-up to 500 users in 1 minute
    { duration: '2m', target: 1000 }, // Ramp-up to 1000 users in the next 2 minutes
    { duration: '2m', target: 2000 }, // Ramp-up to 2000 users in the next 2 minutes
    { duration: '5m', target: 2000 }, // Hold at 2000 users for 5 minutes
    { duration: '2m', target: 0 },    // Ramp-down to 0 users in 2 minutes
  ],
};

export default function () {
  const res = http.get('http://frontend-app-lb-98623121.us-east-1.elb.amazonaws.com/home');

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1); // Pause for 1 second between requests to simulate real user behavior
}


// k6 run ui_loadtest.js --out json=results.json