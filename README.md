# AGRON - Decentralized Agro-Supply Chain Platform

AGRON is a comprehensive decentralized agro-supply chain platform consisting of a native iOS app and Laravel backend API. The platform connects farmers, buyers, and transporters in a seamless ecosystem for crop trading and delivery.

## 🌾 Features

### Core Functionality
- **Multi-Role Authentication**: Farmer, Buyer, Transporter roles with specific permissions
- **Crop Management**: Farmers can list, update, and manage their crop inventory
- **Order System**: Complete order lifecycle from placement to delivery
- **Delivery Tracking**: Real-time delivery job management for transporters
- **Secure Authentication**: Token-based authentication with Laravel Sanctum
- **Role-based Dashboards**: Customized interfaces for each user type
- **Subscription Model**: Premium access with weekly ($3.99) and annual ($39.99) plans

### iOS App Features
- **Native SwiftUI Interface**: Modern, responsive UI design
- **Onboarding Flow**: User-friendly introduction to the platform
- **Subscription Integration**: StoreKit 2 implementation with free trials
- **Role Selection**: Choose your role during registration
- **Dashboard Views**: Role-specific dashboards with relevant information
- **Order Management**: Place, track, and manage orders
- **Crop Browsing**: Browse available crops with filtering options
- **Profile Management**: Update personal information and settings
- **Secure Storage**: Keychain integration for token storage

### Backend API Features
- **RESTful API**: Comprehensive endpoints for all functionality
- **Role-based Access Control**: Secure endpoints based on user roles
- **File Upload**: Image upload for crop photos
- **Database Management**: Efficient MySQL database with proper relationships
- **Validation**: Comprehensive input validation and error handling
- **Pagination**: Efficient data loading with pagination support

## 🏗️ Architecture

### iOS App (SwiftUI)
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
│   └── KeychainService.swift  # Secure token storage
├── Views/                      # SwiftUI views
│   ├── Onboarding/            # Onboarding screens
│   ├── Auth/                  # Login/Register screens
│   ├── Dashboard/             # Role-based dashboards
│   ├── Crop/                  # Crop management views
│   ├── Order/                 # Order management views
│   ├── Profile/               # Profile settings
│   └── Components/            # Reusable UI components
├── Services/                   # Business logic and API
│   ├── SubscriptionManager.swift  # StoreKit 2 subscription handling
│   ├── AuthManager.swift      # Authentication management
│   ├── APIService.swift       # API communication
│   └── KeychainService.swift  # Secure token storage
└── Assets.xcassets/           # App icons and images
```

### Laravel Backend
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

### iOS App Setup
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Agron
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

### Backend Setup
1. **Upload to Namecheap**
   ```bash
   # Upload backend files to public_html/api/
   ```

2. **Database Setup**
   ```bash
   # Create MySQL database
   # Import migrations and seeders
   php artisan migrate
   php artisan db:seed
   ```

3. **Environment Configuration**
   ```bash
   # Configure .env file
   cp .env.example .env
   # Edit with your database credentials
   ```

4. **Generate Application Key**
   ```bash
   php artisan key:generate
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

### Implementation
- **StoreKit 2**: Modern Apple subscription framework
- **Free Trials**: 3-day trial for weekly plan
- **Restore Purchases**: Automatic purchase restoration
- **Subscription Status**: Profile integration for management

## 📱 User Roles & Permissions

### Buyer
- ✅ Browse available crops
- ✅ Place orders
- ✅ Track order status
- ✅ View order history
- ✅ Cancel pending orders
- ❌ Cannot create crop listings
- ❌ Cannot accept delivery jobs

### Transporter
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

### Delivery Jobs Table
```sql
- id (primary key)
- order_id (foreign key)
- transporter_id (nullable)
- status (open, accepted, picked_up, delivered, cancelled)
- pickup_location, delivery_location
- estimated/actual pickup/delivery dates
- created_at, updated_at
```

## 🎨 UI/UX Design

### Design Principles
- **Modern Interface**: Clean, intuitive SwiftUI design
- **Role-based Experience**: Customized interfaces for each user type
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: VoiceOver and accessibility support
- **Dark Mode Support**: Automatic theme adaptation

### Color Scheme
- **Primary**: Green (#34A853) - Agriculture theme
- **Secondary**: Blue (#4285F4) - Trust and reliability
- **Accent**: Orange (#FF9500) - Energy and growth
- **Background**: Light gray (#F8F9FA) - Clean and modern

### Typography
- **Headings**: SF Pro Display Bold
- **Body Text**: SF Pro Text Regular
- **Captions**: SF Pro Text Medium

## 🧪 Testing

### iOS Testing
```bash
# Run unit tests
xcodebuild test -scheme Agron -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme Agron -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AgronUITests
```

### Backend Testing
```bash
# Run PHPUnit tests
php artisan test

# Run specific test suite
php artisan test --filter AuthTest

# Generate coverage report
php artisan test --coverage
```

## 📈 Performance

### iOS App Optimization
- **Lazy Loading**: Images and data loaded on demand
- **Caching**: Local storage for frequently accessed data
- **Background Processing**: Efficient API calls
- **Memory Management**: Proper resource cleanup

### Backend Optimization
- **Database Indexing**: Optimized queries with proper indexes
- **Caching**: Redis caching for frequently accessed data
- **API Pagination**: Efficient data loading
- **Image Optimization**: Compressed image storage

## 🚀 Deployment

### iOS App Store
1. **Archive Build**
   ```bash
   # Archive for App Store
   xcodebuild archive -scheme Agron -archivePath Agron.xcarchive
   ```

2. **Upload to App Store Connect**
   - Use Xcode Organizer
   - Configure app metadata
   - Submit for review

### Backend Deployment (Namecheap)
1. **Upload Files**
   ```bash
   # Upload to public_html/api/
   ```

2. **Database Setup**
   ```bash
   # Create MySQL database
   # Import schema and data
   ```

3. **Environment Configuration**
   ```bash
   # Configure .env file
   # Set production settings
   ```

4. **SSL Certificate**
   - Install SSL certificate for agron.farm
   - Configure HTTPS redirects

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

## ⚙️ Configuration

### iOS Configuration
- **API Base URL**: Update in `APIService.swift`
- **Bundle Identifier**: com.agron.app
- **Minimum iOS Version**: 16.0
- **Target Devices**: iPhone, iPad

### Backend Configuration
- **PHP Version**: 8.1+
- **Database**: MySQL 8.0+
- **Web Server**: Apache/Nginx
- **SSL**: Required for production

## 🔧 Development

### Local Development
1. **iOS**: Use Xcode with iOS Simulator
2. **Backend**: Use Laravel Valet or Docker
3. **Database**: Local MySQL instance
4. **API Testing**: Postman or curl

### Code Standards
- **iOS**: Swift style guide compliance
- **Backend**: PSR-12 coding standards
- **Git**: Conventional commit messages
- **Documentation**: Comprehensive inline comments

## 📞 Support

### Technical Support
- **Email**: support@agron.farm
- **Documentation**: https://agron.farm/docs
- **API Documentation**: https://agron.farm/api/docs

### Bug Reports
- **GitHub Issues**: Report bugs and feature requests
- **Email**: bugs@agron.farm

## 📄 License

This project is proprietary software. All rights reserved.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Basic authentication and user management
- ✅ Crop listing and management
- ✅ Order placement and tracking
- ✅ Delivery job management

### Phase 2 (Planned)
- 🔄 Real-time notifications
- 🔄 Payment integration
- 🔄 Advanced analytics
- 🔄 Mobile app for Android

### Phase 3 (Future)
- 📋 Blockchain integration
- 📋 AI-powered crop recommendations
- 📋 Weather integration
- 📋 Advanced logistics optimization

---

**AGRON** - Connecting farmers, buyers, and transporters in a decentralized agro-supply chain ecosystem. 