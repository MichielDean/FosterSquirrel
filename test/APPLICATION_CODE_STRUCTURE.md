# Application Code Structure Analysis

## Date: October 4, 2025

This document describes the **actual** structure of the Squirrel Feeder application based on code examination, not assumptions.

---

## 📁 View Files That Exist

### 1. HomeView (`lib/views/home/home_view.dart`)
- **Purpose**: Main screen showing list of squirrels
- **Already Tested**: `test/system/views/home_view_test.dart` ✅
- **Coverage**: Loading states, empty state, error handling, list display, navigation

### 2. SquirrelDetailView (`lib/views/squirrel_detail/squirrel_detail_view.dart`)  
- **Purpose**: Comprehensive detail view with 3 tabs
- **Structure**: TabController with 3 tabs: Info, Feeding, Progress
- **State Management**: Manages own loading state, fetches feeding records
- **Navigation**: Opens FeedingRecordForm via FAB

#### Tab Structure:
1. **Info Tab** - Displays squirrel information in Cards:
   - Basic Information Card:
     - Name
     - Found Date
     - Actual Age (days and weeks)
     - Days Since Found
     - Development Stage at Found
     - Current Development Stage  
     - Status
   
   - Weight Information Card:
     - Admission Weight (optional)
     - Current Weight (optional)
   
   - Notes Card (if notes exist)

2. **Feeding Tab** - Displays feeding records:
   - Feeding Schedule Info Card (shows schedule based on current weight)
   - List of FeedingRecordCard widgets
   - Empty state with icon and message
   - Loading indicator during fetch

3. **Progress Tab** - Shows weight tracking:
   - WeightProgressChart widget
   - Progress Summary Card

---

## 🔧 Form Widgets That Exist

### 1. SquirrelFormPage (`lib/widgets/forms/squirrel_form.dart`)
**Purpose**: Full-screen page for adding or editing a squirrel

**AppBar**:
- Title: "Add New Squirrel" or "Edit Squirrel"
- Leading: Close button (X icon)
- Actions: SAVE button (white text button with semi-transparent background)

**Form Fields** (in order):
1. **Name** - TextFormField
   - Label: "Name *"
   - Required validation
   - Prefix icon: pets
   
2. **Date Found** - InkWell with InputDecorator (tappable date picker)
   - Label: "Date Found *"
   - Format: M/d/yyyy
   - Prefix icon: calendar_today
   - Opens DatePicker on tap
   
3. **Development Stage** - DropdownButtonFormField with help button
   - Label: "Development Stage"
   - Dropdown with 7 stages (newborn through adult/release)
   - Format: "Stage Name (min-max weeks)"
   - Prefix icon: timeline
   - Help button (?) opens dialog with stage descriptions
   
4. **Initial Weight** - TextFormField
   - Label: "Initial Weight (grams) *"
   - Required validation
   - Number validation (decimal, > 0, < 1000)
   - Prefix icon: monitor_weight
   - Suffix: "g"
   
5. **Notes** - TextFormField
   - Label: "Notes"
   - Optional
   - 3 lines max
   - Prefix icon: notes
   - Helper text

**Save Button Row** (at bottom):
- Cancel button (outlined)
- Save button (elevated, primary color)

**Navigation**:
- Returns Squirrel object on save
- Returns null on cancel

---

### 2. FeedingRecordForm (`lib/widgets/forms/feeding_record_form.dart`)
**Purpose**: Full-screen page for adding or editing feeding records

**AppBar**:
- Title: "Add Feeding Record" or "Edit Feeding Record"
- Subtitle: "for [Squirrel Name]"
- Leading: Close button (X icon)
- Actions: SAVE button

**Form Fields** (in order):
1. **Feeding Date & Time** - InkWell with InputDecorator
   - Label: "Feeding Date & Time *"
   - Format: "M/d/yyyy at h:mm a"
   - Prefix icon: access_time
   - Opens DatePicker then TimePicker
   
2. **Pre-Feeding Weight** - TextFormField
   - Label: "Pre-Feeding Weight (grams) *"
   - Required, number validation
   - On change: recalculates recommended amount
   - Prefix icon: monitor_weight
   - Suffix: "g"
   
3. **Recommended Amount Display** - Container (read-only display)
   - Shows calculated recommended feeding amount
   - Format: "X.X mL" or "Enter weight to calculate"
   - Blue tinted background
   - Icon: calculate
   
4. **Actual Amount Fed** - TextFormField
   - Label: "Actual Amount Fed (mL)"
   - Optional
   - Number validation if provided
   - Prefix icon: local_drink
   - Suffix: "mL"
   
5. **Post-Feeding Weight** - TextFormField
   - Label: "Post-Feeding Weight (grams)"
   - Optional
   - Validates against starting weight if provided
   - Prefix icon: monitor_weight_outlined
   - Suffix: "g"
   
6. **Food Type** - DropdownButtonFormField
   - Label: "Food Type"
   - Options: Formula, Solid food, Water, Medication, Other
   - Default: Formula
   - Prefix icon: restaurant
   
7. **Notes** - TextFormField
   - Label: "Notes"
   - Optional
   - 3 lines, 500 char max
   - Prefix icon: note

**Save Button Row** (at bottom):
- Cancel button (outlined)
- Save button (elevated) - "Add Record" or "Save Changes"

**Navigation**:
- Returns FeedingRecord on save
- Returns null on cancel

---

## 🎨 Chart Widget

### WeightProgressChart (`lib/widgets/charts/weight_progress_chart.dart`)
- Purpose: Display weight progress over time
- Used in: SquirrelDetailView Progress tab
- Note: Has rendering overflow issues in small test containers

---

## 📊 What System Tests Are Needed

Based on actual code structure:

### 1. SquirrelDetailView System Test
**File**: `test/system/views/squirrel_detail_view_test.dart`

**Test Groups**:
- Basic Display: AppBar with name, 3 tabs exist
- Info Tab Content: Cards display correct data from squirrel model
- Feeding Tab: Empty state, feeding schedule card, feeding records list
- Progress Tab: Chart and summary display
- Tab Navigation: Can switch between tabs
- FAB Navigation: Opens feeding form
- Data Refresh: Reloads feeding records after adding

### 2. SquirrelFormPage System Test  
**File**: `test/system/widgets/squirrel_form_test.dart`

**Test Groups**:
- Initial Display: Title, all fields present
- Pre-population: Edits show existing data
- Field Validation: Name required, weight format/range
- Date Picker: Opens, selects, cancels
- Development Stage Dropdown: Opens, selects
- Help Dialog: Opens with stage info
- Navigation: Cancel vs Save
- Form Submission: Valid data returns Squirrel

### 3. FeedingRecordForm System Test
**File**: `test/system/widgets/feeding_record_form_test.dart`

**Test Groups**:
- Initial Display: Title with squirrel name, all fields
- Pre-population: Edits show existing data
- Field Validation: Required fields, number formats
- Recommended Amount Calculation: Updates when weight changes
- Date/Time Pickers: Opens and selects
- Food Type Dropdown: Opens, selects
- Navigation: Cancel vs Save
- Form Submission: Valid data returns FeedingRecord

---

## ❌ Views That DON'T Exist

These were mentioned in planning but don't exist as separate files:
- ❌ `care_notes_view.dart` - Not implemented
- ❌ `weight_tracking_view.dart` - Exists as chart widget in SquirrelDetailView
- ❌ `feeding_schedule_view.dart` - Info displayed in SquirrelDetailView Feeding tab
- ❌ Separate splash view (empty directory)

---

## 🎯 Key Differences from Assumptions

1. **Forms are full-screen pages**, not modal dialogs
2. **Field labels differ** from what was assumed (e.g., "Pre-Feeding Weight" not "Starting Weight")
3. **Layout uses simple Column/Card structure**, not complex custom widgets
4. **No Card widgets in form layouts** - just InputDecorators and TextFormFields
5. **Date pickers use InkWell + InputDecorator**, not custom widgets
6. **Recommended amount is read-only Container**, not input field
7. **Save buttons are in AppBar AND at bottom** of forms

---

## ✅ Next Steps

1. Create system tests matching the ACTUAL implementation
2. Test against real widget structure and labels
3. Verify form field keys/labels match what's in code
4. Test navigation flows as implemented
5. Handle optional fields properly in tests
