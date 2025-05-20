import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 50, // Simulate 50 users
  duration: '30s', // Run test for 30 seconds
};

export default function () {
  let res = http.get('http://localhost:3000/api/students'); // Change to your API
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
