"""
Simple Flask application for demonstrating Docker best practices.
This application serves as a DevOps learning project example.
"""

from flask import Flask, jsonify, request
import logging
from datetime import datetime
import os

app = Flask(__name__)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Application configuration from environment
APP_ENV = os.getenv('APP_ENV', 'development')
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')


@app.route('/', methods=['GET'])
def home():
    """Root endpoint with basic application info."""
    logger.info("Home endpoint accessed")
    return jsonify({
        'status': 'success',
        'message': 'DevOps and Kubernetes Learning Application',
        'version': APP_VERSION,
        'environment': APP_ENV,
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for container orchestration."""
    logger.info("Health check performed")
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/info', methods=['GET'])
def get_info():
    """Returns application information."""
    logger.info("Info endpoint accessed")
    return jsonify({
        'application': 'DevOps Project',
        'purpose': 'Learning Docker best practices',
        'docker_optimized': True,
        'version': APP_VERSION,
        'container_environment': APP_ENV
    })


@app.route('/api/ready', methods=['GET'])
def readiness_check():
    """Readiness probe for Kubernetes deployments."""
    logger.info("Readiness check performed")
    return jsonify({'ready': True}), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    logger.error(f"Internal error: {error}")
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    logger.info(f"Starting Flask application on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False)
