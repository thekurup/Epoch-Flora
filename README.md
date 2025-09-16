# 🌱 Epoch Flora - Plant E-commerce Application

**Learn Flutter development through a complete, production-ready plant shopping app!**

## 📖 Overview

Epoch Flora is a comprehensive plant e-commerce application that demonstrates advanced Flutter development concepts. This project teaches:

- **Local Database Management** with Hive
- **State Management** with Provider pattern
- **Cross-platform Development** (Mobile + Web)
- **Firebase Integration** for deployment
- **Advanced UI/UX** with animations and gradients
- **Dual User Interfaces** (Customer + Admin)
- **Real-time Order Tracking** with status management

Perfect for developers learning Flutter through a real-world, feature-complete application.

## ✨ Key Features

### 👤 **Customer Features**
- **User Authentication** - Secure registration/login with password hashing
- **Product Catalog** - Browse plants by categories with search functionality  
- **Shopping Cart** - Add/remove items with quantity management and delivery calculations
- **Order Management** - Place orders with real-time tracking and status updates
- **Address Book** - Manage multiple addresses for delivery
- **Favorites System** - Save favorite plants for quick access
- **Profile Management** - Update profile with image upload capability

### 🛠️ **Admin Panel**
- **Admin Authentication** - Separate secure admin login
- **Product Management** - Full CRUD operations for plant inventory
- **Category Management** - Create and manage product categories
- **Order Processing** - Update order status and track deliveries
- **User Management** - View and manage customer accounts
- **Inventory Control** - Complete administrative oversight

## 🛠️ Tech Stack

- **Framework**: Flutter 3.4.1+ (Cross-platform mobile/web)
- **Database**: Hive (Local NoSQL database)
- **State Management**: Provider pattern
- **Authentication**: Custom with SHA-256 password hashing
- **Storage**: SharedPreferences for session management
- **UI Components**: Material Design with custom animations
- **Fonts**: Google Fonts (Poppins, Inter, Playfair Display)
- **Animations**: Lottie animations for enhanced UX
- **Image Handling**: Image picker with local storage
- **Deployment**: Firebase Hosting ready

## 🚀 Installation Guide

### Prerequisites
- Flutter SDK 3.4.1 or higher
- Dart SDK
- Android Studio / VS Code
- Git

### Step-by-Step Installation

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/epoch-flora.git
cd epoch-flora
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Generate Hive Adapters**
```bash
flutter packages pub run build_runner build
```

4. **Run the Application**
```bash
# For mobile development
flutter run

# For web development  
flutter run -d chrome
```

5. **Build for Production**
```bash
# Android APK
flutter build apk --release

# Web build
flutter build web

# iOS (requires macOS)
flutter build ios --release
```

## 📱 How to Use

### **For Customers:**

1. **Getting Started**
   - Launch the app and tap "Get Started" on the splash screen
   - Register a new account or login with existing credentials

2. **Shopping Experience**
   - Browse plants by categories on the home screen
   - Use the search function to find specific plants
   - Tap on any plant to view detailed information
   - Add plants to cart with desired quantity

3. **Checkout Process**
   - Review items in your cart
   - Add or select a delivery address
   - Choose payment method (Cash on Delivery)
   - Place your order and receive confirmation

4. **Order Tracking**
   - View order status in "My Orders" section
   - Track delivery progress with real-time updates
   - View detailed order information and history

### **For Administrators:**

1. **Admin Access**
   - From login screen, tap "Admin Login"  
   - Login with admin credentials (username: arjun, password: arjun24)

2. **Product Management**
   - Add new plants with images, descriptions, and pricing
   - Create and manage product categories
   - Edit existing products or remove discontinued items

3. **Order Processing**
   - View all customer orders in the order list
   - Update order status (Confirmed → Shipped → Delivered)
   - Access detailed customer and shipping information

## 📁 File Structure Explanation

### **Core Application Files**
- `main.dart` - App initialization, Firebase setup, and navigation
- `pubspec.yaml` - Dependencies, assets, and project configuration

### **Database Layer** (`database/`)
- `user_database.dart` - Complete database operations and business logic
- `user_database.g.dart` - Auto-generated Hive type adapters

### **User Interface** (`Screens/`)

#### **Authentication** (`userauth/`)
- `login.dart` - User login with animated UI
- `register-page.dart` - User registration with validation
- `privacypage.dart` - Privacy policy and terms

#### **User Screens** (`user/`)
- `home.dart` - Main dashboard with product categories
- `product_detail_page.dart` - Individual product information
- `cart_page.dart` - Shopping cart management
- `checkout/order flow` - Address selection, order confirmation, success
- `profile_page.dart` - User profile and account management
- `orders/tracking` - Order history and real-time tracking

#### **Admin Panel** (`admin/`)
- `admin_home.dart` - Administrative dashboard
- `product management` - Add, edit, delete products and categories  
- `order management` - Process and track customer orders
- `user_list_page.dart` - Customer account oversight

### **Key Learning Files for Beginners**

**Start Here:**
1. `main.dart` - Understand app initialization and routing
2. `user_database.dart` - Learn Hive database operations
3. `home.dart` - Study state management with Provider
4. `cart_page.dart` - Complex UI with calculations
5. `order_tracker_page.dart` - Advanced animations and tracking

## 🎯 Learning Concepts Demonstrated

### **Database & State Management**
- Local database design with Hive
- CRUD operations implementation
- Provider pattern for state management
- Data validation and error handling

### **UI/UX Design**
- Material Design implementation
- Custom animations and transitions
- Responsive layouts for multiple screen sizes
- Advanced Flutter widgets and compositions

### **Authentication & Security**
- User registration and login systems
- Password hashing with SHA-256
- Session management
- Role-based access (User vs Admin)

### **E-commerce Functionality**
- Shopping cart logic and calculations
- Order processing workflows
- Payment integration concepts
- Inventory management

## 📸 Screenshots / Demo

*Add screenshots of your app here showing:*
- Splash screen and onboarding
- Home screen with product categories
- Product detail and cart pages
- Order tracking interface
- Admin panel dashboard

## 🔮 Future Scope

### **Planned Enhancements**
- **Online Payments** - Integrate payment gateways (Stripe, Razorpay)
- **Push Notifications** - Order updates and promotional messages
- **Advanced Search** - Filters by price, plant type, care level
- **Social Features** - Plant care tips, user reviews, community
- **Analytics Dashboard** - Sales reports and user behavior tracking
- **Multi-language Support** - Internationalization for global reach

### **Technical Improvements**
- **Backend Integration** - Django/Node.js API for cloud sync
- **Advanced Caching** - Improved performance and offline support
- **Unit Testing** - Comprehensive test coverage
- **CI/CD Pipeline** - Automated testing and deployment
- **Performance Optimization** - Image compression and lazy loading

## 🤝 Contributing

This project is perfect for learning Flutter development. Feel free to:
- Fork the repository and experiment
- Add new features or improve existing ones
- Submit pull requests with enhancements
- Report bugs or suggest improvements

## 📞 Contact

For questions about this learning project:
- **Developer**: Arjun Kurup
- **Email**: arjunurup242gmail.com
- **GitHub**: https://github.com/thekurup

## 📄 License

This project is created for educational purposes. Feel free to use it for learning Flutter development.

---

**"Rooted in every seedling, lies the promise of a greener tomorrow" - Epoch Flora**
