# AGRON Backend API

Laravel backend for the AGRON decentralized agro-supply chain iOS app.

## Features

- **Authentication**: Laravel Sanctum for token-based authentication
- **Role-based Access**: Farmer, Buyer, Transporter roles with specific permissions
- **Crop Management**: CRUD operations for crop listings
- **Order System**: Complete order lifecycle management
- **Delivery Jobs**: Transporter job assignment and tracking
- **Real-time Updates**: WebSocket support for live updates
- **File Upload**: Image upload for crop photos
- **API Documentation**: Comprehensive API endpoints

## Tech Stack

- **Framework**: Laravel 10.x
- **Database**: MySQL 8.0
- **Authentication**: Laravel Sanctum
- **File Storage**: Local/Cloud storage
- **API**: RESTful API with JSON responses
- **Validation**: Laravel Form Requests
- **Testing**: PHPUnit with feature tests

## Requirements

- PHP 8.1+
- Composer 2.0+
- MySQL 8.0+
- Node.js 16+ (for asset compilation)
- Apache/Nginx web server

## Installation

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd agron-backend

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 2. Database Configuration

Edit `.env` file with your database credentials:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agron_db
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### 3. Database Setup

```bash
# Run migrations
php artisan migrate

# Seed database with sample data
php artisan db:seed

# Create storage link
php artisan storage:link
```

### 4. Sanctum Configuration

```bash
# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 5. Environment Variables

Configure additional environment variables in `.env`:

```env
# App Configuration
APP_NAME="AGRON API"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://agron.farm

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agron_db
DB_USERNAME=your_username
DB_PASSWORD=your_password

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=your_smtp_host
MAIL_PORT=587
MAIL_USERNAME=your_email
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@agron.farm
MAIL_FROM_NAME="AGRON"

# File Storage
FILESYSTEM_DISK=public

# Sanctum Configuration
SANCTUM_STATEFUL_DOMAINS=agron.farm
SESSION_DOMAIN=.agron.farm
```

## Project Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Api/
│   │   │   ├── AuthController.php
│   │   │   ├── CropController.php
│   │   │   ├── OrderController.php
│   │   │   └── DeliveryJobController.php
│   │   └── Controller.php
│   ├── Requests/
│   │   ├── LoginRequest.php
│   │   ├── RegisterRequest.php
│   │   ├── CropRequest.php
│   │   └── OrderRequest.php
│   └── Resources/
│       ├── UserResource.php
│       ├── CropResource.php
│       └── OrderResource.php
├── Models/
│   ├── User.php
│   ├── Crop.php
│   ├── Order.php
│   └── DeliveryJob.php
├── Services/
│   ├── CropService.php
│   ├── OrderService.php
│   └── NotificationService.php
└── Providers/
    └── AppServiceProvider.php

database/
├── migrations/
│   ├── create_users_table.php
│   ├── create_crops_table.php
│   ├── create_orders_table.php
│   └── create_delivery_jobs_table.php
└── seeders/
    ├── DatabaseSeeder.php
    ├── UserSeeder.php
    └── CropSeeder.php

routes/
└── api.php

config/
├── sanctum.php
├── cors.php
└── filesystems.php
```

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | User registration |
| POST | `/api/login` | User login |
| POST | `/api/logout` | User logout |
| GET | `/api/user` | Get current user |

### Crops

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/crops` | List all crops |
| POST | `/api/crops` | Create new crop |
| GET | `/api/crops/{id}` | Get crop details |
| PUT | `/api/crops/{id}` | Update crop |
| DELETE | `/api/crops/{id}` | Delete crop |

### Orders

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/orders` | List user orders |
| POST | `/api/orders` | Create new order |
| GET | `/api/orders/{id}` | Get order details |
| PATCH | `/api/orders/{id}/status` | Update order status |

### Delivery Jobs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/jobs` | List available jobs |
| POST | `/api/jobs/accept` | Accept delivery job |
| PATCH | `/api/jobs/{id}/pickup` | Mark as picked up |
| PATCH | `/api/jobs/{id}/delivered` | Mark as delivered |

## Authentication Flow

1. **Registration**: User registers with email, password, and role
2. **Login**: User logs in and receives access token
3. **Token Usage**: Include token in Authorization header: `Bearer {token}`
4. **Logout**: Token is revoked on logout

## Role-based Access Control

### Farmer
- Create, read, update, delete own crops
- View orders for their crops
- Update order status (confirmed, shipped)

### Buyer
- Browse all available crops
- Place orders
- Track order status
- View order history

### Transporter
- View available delivery jobs
- Accept delivery jobs
- Update job status (picked up, delivered)
- View job history

## Database Schema

### Users Table
- id (primary key)
- name
- email (unique)
- password
- phone
- role (farmer, buyer, transporter)
- location
- created_at, updated_at

### Crops Table
- id (primary key)
- farmer_id (foreign key)
- name
- type
- quantity
- unit
- price
- currency
- location
- availability_date
- description
- status
- created_at, updated_at

### Orders Table
- id (primary key)
- crop_id (foreign key)
- buyer_id (foreign key)
- farmer_id (foreign key)
- quantity
- unit
- total_price
- currency
- status
- pickup_location
- delivery_location
- transporter_id (foreign key, nullable)
- created_at, updated_at

### Delivery Jobs Table
- id (primary key)
- order_id (foreign key)
- transporter_id (foreign key, nullable)
- status
- pickup_location
- delivery_location
- estimated_pickup_date
- estimated_delivery_date
- created_at, updated_at

## Security Features

- **Token-based Authentication**: Laravel Sanctum
- **Password Hashing**: Bcrypt encryption
- **Input Validation**: Form Request validation
- **CORS Configuration**: Cross-origin resource sharing
- **Rate Limiting**: API rate limiting
- **SQL Injection Protection**: Eloquent ORM
- **XSS Protection**: Output escaping

## Testing

```bash
# Run all tests
php artisan test

# Run specific test
php artisan test --filter CropTest

# Generate test coverage
php artisan test --coverage
```

## Deployment

### Namecheap Shared Hosting

1. **Upload Files**: Upload all files to public_html/api/
2. **Database Setup**: Create MySQL database and import schema
3. **Environment**: Configure .env file with production settings
4. **Permissions**: Set proper file permissions (755 for directories, 644 for files)
5. **Storage**: Create storage/app/public directory with write permissions
6. **Cache**: Run `php artisan config:cache` and `php artisan route:cache`

### Production Checklist

- [ ] Set APP_ENV=production
- [ ] Set APP_DEBUG=false
- [ ] Configure database credentials
- [ ] Set up SSL certificate
- [ ] Configure mail settings
- [ ] Set up file storage
- [ ] Run database migrations
- [ ] Seed initial data
- [ ] Configure web server (Apache/Nginx)
- [ ] Set up domain (agron.farm)
- [ ] Test all API endpoints
- [ ] Monitor error logs

## Monitoring

- **Error Logging**: Laravel logs in storage/logs/
- **Database Monitoring**: MySQL slow query log
- **API Monitoring**: Response times and error rates
- **Security Monitoring**: Failed authentication attempts

## Support

For technical support or questions:
- Email: support@agron.farm
- Documentation: https://agron.farm/api/docs
- GitHub Issues: Report bugs and feature requests

## License

This project is proprietary software. All rights reserved. 