#!/bin/sh

# Generate the env-config.js file
cat <<EOF > /usr/share/nginx/html/env-config.js
window._env_ = {
  REACT_APP_API_URL: "$REACT_APP_API_URL",
  // Add other environment variables here
};
EOF

# Start Nginx
nginx -g "daemon off;"