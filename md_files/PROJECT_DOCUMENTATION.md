# CourseBundler - Complete Project Documentation

## 📋 Project Overview

**CourseBundler** is a full-stack online learning platform (like Udemy) built with:

- **Backend**: Node.js, Express.js, MongoDB, JWT Authentication
- **Frontend**: React.js, Redux, Chakra UI
- **Payment**: Razorpay Integration
- **Storage**: Cloudinary (for images and videos)
- **Email**: Nodemailer (for password reset and notifications)

---

## 👥 User Roles

### 1. **USER** (Regular User)

### 2. **ADMIN** (Administrator)

---

## 🔐 Authentication & Authorization

### Public Routes (No Login Required)

- Home Page (`/`)
- Courses Listing (`/courses`)
- About Page (`/about`)
- Contact Page (`/contact`)
- Course Request Page (`/request`)
- Login (`/login`)
- Register (`/register`)
- Forgot Password (`/forgetpassword`)
- Reset Password (`/resetpassword/:token`)

### Protected Routes (Login Required)

- Profile (`/profile`)
- Update Profile (`/updateprofile`)
- Change Password (`/changepassword`)
- Course Page (`/course/:id`) - Requires active subscription
- Subscribe (`/subscribe`)
- Payment Success (`/paymentsuccess`)
- Payment Fail (`/paymentfail`)

### Admin-Only Routes

- Admin Dashboard (`/admin/dashboard`)
- Create Course (`/admin/createcourse`)
- Admin Courses (`/admin/courses`)
- Users Management (`/admin/users`)

---

## 👤 USER ROLE - Complete Functionality

### **User Dashboard (Profile Page)**

#### 1. **Profile Management**

- ✅ View Profile Information
  - Name, Email, Account Creation Date
  - Profile Avatar/Photo
- ✅ Update Profile
  - Change Name
  - Change Email
- ✅ Change Profile Picture
  - Upload new avatar (stored in Cloudinary)
- ✅ Change Password
  - Requires old password verification
  - Updates to new password (hashed with bcrypt)

#### 2. **Subscription Management**

- ✅ **Subscribe to Premium**
  - Buy subscription via Razorpay
  - Monthly subscription (12 months plan)
  - Payment verification with signature validation
  - Subscription status tracking
- ✅ **Cancel Subscription**
  - Cancel active subscription
  - Automatic refund if cancelled within 7 days
  - Subscription status updated to inactive

#### 3. **Playlist Management**

- ✅ **Add Courses to Playlist**
  - Add courses from course listing page
  - Save courses for later viewing
- ✅ **View Playlist**
  - See all saved courses with posters
  - Quick access to watch courses
- ✅ **Remove from Playlist**
  - Delete courses from playlist

#### 4. **Course Access**

- ✅ **Browse All Courses**
  - View all available courses
  - Search courses by keyword
  - Filter by category:
    - Web Development
    - Artificial Intelligence
    - Data Structure & Algorithm
    - App Development
    - Data Science
    - Game Development
- ✅ **View Course Details**
  - Course title, description
  - Creator name
  - Number of lectures
  - View count
  - Course poster/image
- ✅ **Watch Course Lectures** (Requires Active Subscription)
  - Watch video lectures
  - View lecture descriptions
  - Navigate between lectures
  - Video player with controls
  - **Note**: Users without active subscription are redirected to subscribe page

#### 5. **Other Features**

- ✅ **Contact Form**
  - Send messages to admin
  - Email notifications sent to admin
- ✅ **Course Request**
  - Request new courses
  - Email notifications sent to admin
- ✅ **Logout**
  - Clear authentication token
  - Session termination

---

## 👨‍💼 ADMIN ROLE - Complete Functionality

### **Admin Dashboard** (`/admin/dashboard`)

#### 1. **Analytics & Statistics**

- ✅ **Real-time Statistics**
  - Total Users count
  - Active Subscriptions count
  - Total Course Views
  - Percentage changes (month-over-month)
  - Profit/Loss indicators (up/down arrows)
- ✅ **Visual Charts**
  - **Line Chart**: Course views over time (12 months data)
  - **Doughnut Chart**: Users distribution (Subscribed vs Non-subscribed)
  - **Progress Bars**: Visual representation of growth percentages
- ✅ **Auto-updating Stats**
  - Stats update automatically when:
    - New user registers
    - User subscription changes
    - Course views increase
  - Stats stored in MongoDB with timestamps

#### 2. **Course Management** (`/admin/courses`)

##### **View All Courses**

- ✅ Table view showing:
  - Course ID
  - Course Poster/Thumbnail
  - Course Title
  - Category
  - Creator Name
  - View Count
  - Number of Lectures
  - Action Buttons

##### **Course Operations**

- ✅ **View Course Lectures**
  - Open modal to see all lectures in a course
  - View lecture titles and descriptions
  - See video details
- ✅ **Add Lectures to Course**
  - Upload video files (max 100MB)
  - Add lecture title and description
  - Videos stored in Cloudinary
  - Auto-update lecture count
- ✅ **Delete Lectures**
  - Remove individual lectures from courses
  - Delete video from Cloudinary
  - Update course lecture count
- ✅ **Delete Entire Course**
  - Delete course and all its lectures
  - Remove all videos and poster from Cloudinary
  - Clean up database records

#### 3. **Create New Course** (`/admin/createcourse`)

- ✅ **Course Creation Form**
  - Course Title (required)
  - Course Description (required)
  - Category Selection (dropdown)
  - Creator Name (required)
  - Course Poster/Thumbnail Image (required)
  - Image preview before upload
- ✅ **Post Upload**
  - Course created in database
  - Poster uploaded to Cloudinary
  - Admin can then add lectures to the course

#### 4. **User Management** (`/admin/users`)

##### **View All Users**

- ✅ Table showing:
  - User ID
  - User Name
  - Email Address
  - Role (user/admin)
  - Subscription Status (Active/Not Active)
  - Action Buttons

##### **User Operations**

- ✅ **Change User Role**
  - Toggle between "user" and "admin" roles
  - Promote regular users to admin
  - Demote admins to regular users
- ✅ **Delete Users**
  - Remove users from system
  - Delete user avatar from Cloudinary
  - Clean up user data
  - **Note**: Admin cannot delete themselves

---

## 🔧 Technical Features

### **Backend Features**

#### **Authentication & Security**

- JWT-based authentication
- Password hashing with bcrypt (10 rounds)
- HTTP-only cookies for token storage
- CORS configuration for frontend
- Protected routes with middleware
- Role-based access control

#### **Database Models**

1. **User Model**

   - Name, Email, Password (hashed)
   - Role (user/admin)
   - Avatar (Cloudinary)
   - Subscription (id, status)
   - Playlist (array of courses)
   - Reset password tokens

2. **Course Model**

   - Title, Description, Category
   - Poster (Cloudinary image)
   - Lectures array (videos stored in Cloudinary)
   - Views counter
   - Number of videos
   - Created by (creator name)
   - Timestamps

3. **Payment Model**

   - Razorpay payment details
   - Subscription ID
   - Payment verification signatures
   - Timestamps

4. **Stats Model**
   - Users count
   - Subscriptions count
   - Views count
   - Auto-updated via MongoDB change streams
   - Timestamps

#### **API Endpoints**

**User Routes** (`/api/v1`)

- `POST /register` - Register new user
- `POST /login` - User login
- `GET /logout` - User logout
- `GET /me` - Get current user profile
- `DELETE /me` - Delete own profile
- `PUT /changepassword` - Change password
- `PUT /updateprofile` - Update profile
- `PUT /updateprofilepicture` - Update avatar
- `POST /forgetpassword` - Request password reset
- `PUT /resetpassword/:token` - Reset password
- `POST /addtoplaylist` - Add course to playlist
- `DELETE /removefromplaylist` - Remove from playlist
- `GET /admin/users` - Get all users (admin only)
- `PUT /admin/user/:id` - Update user role (admin only)
- `DELETE /admin/user/:id` - Delete user (admin only)

**Course Routes** (`/api/v1`)

- `GET /courses` - Get all courses (public)
- `POST /createcourse` - Create course (admin only)
- `GET /course/:id` - Get course lectures (subscribers only)
- `POST /course/:id` - Add lecture (admin only)
- `DELETE /course/:id` - Delete course (admin only)
- `DELETE /lecture` - Delete lecture (admin only)

**Payment Routes** (`/api/v1`)

- `GET /subscribe` - Create subscription (users only)
- `POST /paymentverification` - Verify payment
- `GET /razorpaykey` - Get Razorpay public key
- `DELETE /subscribe/cancel` - Cancel subscription

**Other Routes** (`/api/v1`)

- `POST /contact` - Contact form submission
- `POST /courserequest` - Request new course
- `GET /admin/stats` - Get dashboard statistics (admin only)

### **Frontend Features**

#### **State Management (Redux)**

- User state (authentication, profile)
- Course state (courses, lectures)
- Admin state (dashboard stats, users, courses)
- Subscription state
- Profile state
- Other state (contact, requests)

#### **UI Components**

- Responsive design with Chakra UI
- Protected routes with redirects
- Toast notifications for feedback
- Loading states and skeletons
- Image upload with preview
- Video player for course lectures
- Charts and graphs for analytics
- Modal dialogs for course management

#### **Payment Integration**

- Razorpay payment gateway
- Subscription management
- Payment verification
- Refund handling (7-day policy)

---

## 📊 Database Schema Summary

### **User Collection**

```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  role: "user" | "admin",
  subscription: {
    id: String,
    status: String
  },
  avatar: {
    public_id: String,
    url: String
  },
  playlist: [{
    course: ObjectId,
    poster: String
  }],
  resetPasswordToken: String,
  resetPasswordExpire: Date
}
```

### **Course Collection**

```javascript
{
  title: String,
  description: String,
  category: String,
  poster: {
    public_id: String,
    url: String
  },
  lectures: [{
    title: String,
    description: String,
    video: {
      public_id: String,
      url: String
    }
  }],
  views: Number,
  numOfVideos: Number,
  createdBy: String
}
```

### **Payment Collection**

```javascript
{
  razorpay_signature: String,
  razorpay_payment_id: String,
  razorpay_subscription_id: String,
  createdAt: Date
}
```

### **Stats Collection**

```javascript
{
  users: Number,
  subscription: Number,
  views: Number,
  createdAt: Date
}
```

---

## 🔄 Workflows

### **User Registration Flow**

1. User fills registration form (name, email, password, avatar)
2. Avatar uploaded to Cloudinary
3. Password hashed with bcrypt
4. User created in database
5. JWT token generated and sent via cookie
6. User redirected to profile

### **Login Flow**

1. User enters email and password
2. System finds user and compares password
3. JWT token generated
4. Token stored in HTTP-only cookie
5. User redirected to profile/courses

### **Subscription Flow**

1. User clicks "Subscribe"
2. Razorpay subscription created
3. Payment popup opens
4. User completes payment
5. Payment verified with signature
6. Subscription status updated to "active"
7. User can now access course lectures

### **Course Creation Flow (Admin)**

1. Admin fills course creation form
2. Poster image uploaded to Cloudinary
3. Course created in database
4. Admin can add lectures to course
5. Videos uploaded to Cloudinary
6. Course becomes available to users

### **Password Reset Flow**

1. User requests password reset
2. Reset token generated and hashed
3. Email sent with reset link
4. User clicks link (valid for 15 minutes)
5. User enters new password
6. Password updated and token invalidated

---

## 🎯 Key Features Summary

### **For Regular Users:**

- ✅ User registration and authentication
- ✅ Profile management
- ✅ Course browsing and search
- ✅ Subscription purchase
- ✅ Course playlist management
- ✅ Watch course lectures (with subscription)
- ✅ Contact admin
- ✅ Request new courses

### **For Admins:**

- ✅ All user features
- ✅ Analytics dashboard with charts
- ✅ Create and manage courses
- ✅ Add/delete lectures
- ✅ Manage users (view, change role, delete)
- ✅ View statistics and trends
- ✅ No subscription required (admin bypass)

---

## 🛠️ Technology Stack

**Backend:**

- Node.js
- Express.js
- MongoDB (Mongoose)
- JWT Authentication
- Bcrypt (password hashing)
- Razorpay (payments)
- Cloudinary (media storage)
- Nodemailer (email)
- Multer (file uploads)
- Node-cron (scheduled tasks)

**Frontend:**

- React.js
- Redux Toolkit
- React Router
- Chakra UI
- Axios
- Chart.js
- React Hot Toast
- Protected Route React

---

## 📝 Environment Variables Required

```
PORT=5001
MONGO_URI=mongodb://...
JWT_SECRET=...
FRONTEND_URL=...
SMTP_HOST=...
SMTP_PORT=...
SMTP_USER=...
SMTP_PASS=...
CLOUDINARY_CLIENT_NAME=...
CLOUDINARY_CLIENT_API=...
CLOUDINARY_CLIENT_SECRET=...
RAZORPAY_API_KEY=...
RAZORPAY_API_SECRET=...
PLAN_ID=...
REFUND_DAYS=7
MY_MAIL=...
```

---

## 🚀 Getting Started

1. Install dependencies: `npm install` (both backend and frontend)
2. Configure environment variables
3. Start backend: `npm run dev` (port 5001)
4. Start frontend: `npm start` (port 3000)
5. Access application at `http://localhost:3000`

---

## 📌 Important Notes

- **Subscription Required**: Regular users need active subscription to watch course lectures
- **Admin Bypass**: Admins can access all courses without subscription
- **Refund Policy**: 7-day refund window for subscription cancellations
- **File Limits**: Video uploads max 100MB, images handled by Cloudinary
- **Auto Stats**: Statistics update automatically via MongoDB change streams
- **Security**: Passwords are hashed, tokens in HTTP-only cookies, CORS configured

---

This documentation covers all functionalities available in your CourseBundler application for both User and Admin roles!
