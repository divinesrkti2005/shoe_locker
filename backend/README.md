# Sneak Bid Backend

A Node.js/Express.js backend API for Sneak Bid - a sneaker marketplace and bidding platform.

## Features

- **Shoe Management**: Add, update, and manage sneaker listings with images, prices, and available sizes
- **User Authentication**: JWT-based authentication for customers and admins
- **Shopping Cart & Wishlist**: Save favorite shoes and manage shopping cart
- **Order Management**: Complete order processing with shipping and delivery tracking
- **Payment Integration**: Khalti payment gateway integration
- **Image Upload**: Multer-based image upload for shoe photos
- **Search & Filtering**: Advanced search with category, brand, price, and size filters

## API Endpoints

### Shoes
- `POST /api/v1/shoes` - Create a new shoe listing
- `GET /api/v1/shoes` - Get all shoes with filters
- `GET /api/v1/shoes/featured` - Get featured shoes
- `GET /api/v1/shoes/category/:category` - Get shoes by category
- `GET /api/v1/shoes/:id` - Get shoe by ID
- `PUT /api/v1/shoes/:id` - Update shoe
- `DELETE /api/v1/shoes/:id` - Delete shoe

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `GET /api/v1/auth/me` - Get current user

### Orders & Wishlist
- `POST /api/v1/bookings` - Create new order
- `GET /api/v1/wishlist` - Get user wishlist
- `POST /api/v1/wishlist` - Add shoe to wishlist

## Tech Stack

- Node.js & Express.js
- MongoDB with Mongoose
- JWT Authentication
- Multer for file uploads
- Khalti Payment Gateway
- Security middleware (Helmet, XSS protection)

## Installation

1. Clone the repository
2. Install dependencies: `npm install`
3. Set up environment variables in `config/config.env`
4. Run the server: `npm run dev`
