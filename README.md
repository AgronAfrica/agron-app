# 🌾 AGRON - Decentralized Agricultural Marketplace

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![Laravel](https://img.shields.io/badge/Laravel-10.x-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.1+-purple.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**AGRON** is a comprehensive decentralized agricultural marketplace that connects farmers, buyers, and transporters in a seamless ecosystem for crop trading and delivery. Built with native iOS SwiftUI and Laravel backend.

## 🚀 Features

### 🌱 Core Platform
- **Multi-Role Authentication**: Farmer, Buyer, Transporter roles with specific permissions
- **Crop Management**: Farmers can list, update, and manage their crop inventory
- **Order System**: Complete order lifecycle from placement to delivery
- **Delivery Tracking**: Real-time delivery job management for transporters
- **Subscription Model**: Premium access with weekly ($3.99) and annual ($39.99) plans

### 📱 iOS App Features
- **Native SwiftUI Interface**: Modern, responsive UI design
- **Onboarding Flow**: User-friendly introduction to the platform
- **Subscription Integration**: StoreKit 2 implementation with free trials
- **Role Selection**: Choose your role during registration
- **Dashboard Views**: Role-specific dashboards with relevant information
- **Order Management**: Place, track, and manage orders
- **Crop Browsing**: Browse available crops with filtering options
- **Profile Management**: Update personal information and settings
- **Secure Storage**: Keychain integration for token storage

### 🔧 Backend API Features
- **RESTful API**: Comprehensive endpoints for all functionality
- **Role-based Access Control**: Secure endpoints based on user roles
- **File Upload**: Image upload for crop photos
- **Database Management**: Efficient MySQL database with proper relationships
- **Validation**: Comprehensive input validation and error handling
- **Pagination**: Efficient data loading with pagination support

## 🏗️ Architecture

### 📱 iOS App (SwiftUI)
```
Agron/
├── AgronApp.swift              # Main app entry point
├── ContentView.swift           # Root view with navigation logic
├── Models/                     # Data models
│   ├── User.swift             # User model with roles
│   ├── Crop.swift             # Crop model with status
│   ├── Order.swift            # Order model with lifecycle
│   └── DeliveryJob.swift      # Delivery job model
├── Services/                   # Business logic and API
│   ├── AuthManager.swift      # Authentication management
│   ├── APIService.swift       # API communication
│   ├── KeychainService.swift  # Secure token storage
│   └── SubscriptionManager.swift # StoreKit 2 integration
├── Views/                      # SwiftUI views
│   ├── Onboarding/            # Onboarding screens
│   ├── Auth/                  # Login/Register screens
│   ├── Dashboard/             # Role-based dashboards
│   ├── Crop/                  # Crop management views
│   ├── Order/                 # Order management views
│   ├── Profile/               # Profile settings
│   └── Components/            # Reusable UI components
└── Assets.xcassets/           # App icons and images
```

### 🖥️ Laravel Backend
```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/   # API controllers
│   │   ├── Requests/          # Form validation
│   │   └── Resources/         # API response formatting
│   ├── Models/                # Eloquent models
│   └── Services/              # Business logic services
├── database/
│   ├── migrations/            # Database schema
│   └── seeders/              # Sample data
├── routes/
│   └── api.php               # API routes
└── config/                   # Configuration files
```

## 🚀 Quick Start

### Prerequisites
- **iOS Development**: Xcode 15+, iOS 16+
- **Backend**: PHP 8.1+, Composer, MySQL 8.0+
- **Domain**: agron.farm (configured on Namecheap)

### 📱 iOS App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/agron-app.git
   cd agron-app
   ```

2. **Open in Xcode**
   ```bash
   open Agron.xcodeproj
   ```

3. **Configure StoreKit Testing**
   - Go to **Product** → **Scheme** → **Edit Scheme**
   - Select **Run** → **Options**
   - Set **StoreKit Configuration** to `StoreKitConfig.storekit`

4. **Configure API Base URL**
   - Update `APIService.swift` with your backend URL
   - Default: `https://agron.farm/api`

5. **Build and Run**
   - Select iOS Simulator or device
   - Press Cmd+R to build and run

### 🖥️ Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend-app
   ```

2. **Install dependencies**
   ```bash
   composer install
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Database configuration**
   ```bash
   # Edit .env file with your database credentials
   php artisan migrate
   php artisan db:seed
   ```

5. **Start development server**
   ```bash
   php artisan serve
   ```

## 💰 Subscription Model

### Plans Available
- **Weekly Plan**: $3.99/week with 3-day free trial
- **Annual Plan**: $39.99/year (80% savings)

### Features Included
- ✅ Unlimited crop listings
- ✅ Priority delivery job access
- ✅ Advanced analytics and insights
- ✅ Real-time notifications
- ✅ Premium customer support
- ✅ Full platform access

## 📱 User Roles & Permissions

### 👨‍🌾 Farmer
- ✅ Create and manage crop listings
- ✅ Set prices and availability
- ✅ Track orders and manage deliveries
- ✅ Access market insights and analytics
- ❌ Cannot place orders or accept delivery jobs

### 🛒 Buyer
- ✅ Browse available crops
- ✅ Place orders
- ✅ Track order status
- ✅ View order history
- ✅ Cancel pending orders
- ❌ Cannot create crop listings
- ❌ Cannot accept delivery jobs

### 🚚 Transporter
- ✅ View available delivery jobs
- ✅ Accept delivery jobs
- ✅ Update job status (pickup, delivered)
- ✅ View job history
- ✅ Track active deliveries
- ❌ Cannot create crop listings
- ❌ Cannot place orders

## 🔐 Security Features

### Authentication
- **Laravel Sanctum**: Token-based authentication
- **Secure Token Storage**: iOS Keychain integration
- **Password Hashing**: Bcrypt encryption
- **Session Management**: Automatic token refresh

### Data Protection
- **Input Validation**: Comprehensive form validation
- **SQL Injection Protection**: Eloquent ORM
- **XSS Protection**: Output escaping
- **CORS Configuration**: Cross-origin resource sharing
- **Rate Limiting**: API rate limiting

### iOS Security
- **Keychain Storage**: Secure token storage
- **Network Security**: HTTPS enforcement
- **App Transport Security**: Secure network communication
- **Biometric Authentication**: Touch ID/Face ID support

## 📊 Database Schema

### Users Table
```sql
- id (primary key)
- name
- email (unique)
- password (hashed)
- phone
- role (farmer, buyer, transporter)
- location
- created_at, updated_at
```

### Crops Table
```sql
- id (primary key)
- farmer_id (foreign key)
- name, type, quantity, unit
- price, currency
- location, availability_date
- description, status
- image_path
- created_at, updated_at
```

### Orders Table
```sql
- id (primary key)
- crop_id, buyer_id, farmer_id (foreign keys)
- quantity, unit, total_price, currency
- status (pending, confirmed, in_transit, delivered, cancelled)
- pickup_location, delivery_location
- transporter_id (nullable)
- created_at, updated_at
```

## 🧪 Testing

### iOS Testing
- **Unit Tests**: Core functionality testing
- **UI Tests**: User interface testing
- **StoreKit Testing**: Subscription flow testing
- **Integration Tests**: API integration testing

### Backend Testing
- **Feature Tests**: API endpoint testing
- **Unit Tests**: Model and service testing
- **Database Tests**: Migration and seeder testing

## 📋 Sample Data

### Test Users
- **Farmers**: farmer@agron.farm, sarah@agron.farm, mohammed@agron.farm
- **Buyers**: buyer@agron.farm, david@agron.farm, fatima@agron.farm
- **Transporters**: transporter@agron.farm, aisha@agron.farm, chukwudi@agron.farm
- **Password**: password (for all test accounts)

### Sample Crops
- Fresh Cassava, Premium Rice, Sweet Corn
- Fresh Tomatoes, Hot Peppers, Yam Tubers
- Plantain, Fresh Beans, Cocoa Beans, Groundnuts

## 🚀 Deployment

### iOS App Store
1. **Archive Build**
   ```bash
   xcodebuild archive -scheme Agron -archivePath Agron.xcarchive
   ```

2. **Upload to App Store Connect**
   - Use Xcode Organizer
   - Configure app metadata
   - Submit for review

### Backend Deployment (Google Cloud Run)
1. **Build Docker Image**
   ```bash
   docker build -t agron-backend .
   ```

2. **Deploy to Cloud Run**
   ```bash
   gcloud run deploy agron-backend --image agron-backend --platform managed
   ```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

### Technical Support
- **Email**: support@agron.farm
- **Documentation**: https://agron.farm/docs
- **Issues**: [GitHub Issues](https://github.com/yourusername/agron-app/issues)

### Community
- **Discord**: [Join our community](https://discord.gg/agron)
- **Twitter**: [@agron_app](https://twitter.com/agron_app)
- **LinkedIn**: [Agron Company](https://linkedin.com/company/agron)

## 🙏 Acknowledgments

- **Apple**: For SwiftUI and StoreKit 2
- **Laravel**: For the amazing PHP framework
- **Community**: For feedback and contributions
- **Farmers**: For inspiring this platform

---

**Made with ❤️ for the agricultural community** 