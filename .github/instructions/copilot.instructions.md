---
applyTo: '**'
---

## Context7 Usage Requirements - MANDATORY

**🚨 CRITICAL: You are trained on OLD data. Libraries update constantly. You MUST use Context7 to verify current APIs, options, and patterns. 🚨**

**ALWAYS use Context7 BEFORE writing any code involving external libraries or frameworks:**

### When Context7 is REQUIRED (Not Optional):

1. **BEFORE using ANY package/library API** - Configuration options, method signatures, and parameters change between versions
2. **BEFORE suggesting ANY configuration options** - Options get deprecated, renamed, or removed in newer versions
3. **BEFORE implementing framework features** - Best practices and recommended patterns evolve
4. **BEFORE suggesting package versions** - Verify compatible and current versions
5. **BEFORE creating custom implementations** - Standard solutions may already exist
6. **BEFORE using build tools** (build_runner, code generators, etc.) - Build options and flags change frequently

### Specific Examples Where Context7 is MANDATORY:

- **Drift/Moor**: Migration strategies, build options, query syntax
- **Provider/Riverpod**: State management patterns and lifecycle
- **Flutter packages**: Any third-party package configuration
- **Build configuration**: pubspec.yaml, build.yaml, analysis_options.yaml options
- **Code generation**: Generator options and parameters
- **Testing frameworks**: Test utilities and mocking patterns

### The Correct Workflow:

1. **User requests feature** using library X
2. **YOU MUST** call `mcp_context7_resolve-library-id` to find library
3. **YOU MUST** call `mcp_context7_get-library-docs` with specific topic
4. **READ** the returned documentation carefully
5. **IMPLEMENT** exactly what Context7 shows (not what you remember)
6. **VERIFY** all parameters, options, and method names match documentation

### ❌ NEVER Do This:
```dart
// DON'T assume you know the options!
options:
  generate_connect_constructor: true  // ← Is this still valid?
  null_aware_type_converters: true    // ← Does this exist?
  some_option_you_remember: true      // ← Might be deprecated!
```

### ✅ ALWAYS Do This:
```dart
// 1. Query Context7 for current Drift build options
// 2. Read documentation 
// 3. Use ONLY options confirmed in docs
options:
  store_date_time_values_as_text: true  // ✓ Verified in Context7
```

### Red Flags That Mean You Should Have Used Context7:

- ❌ User says "that option doesn't exist" or "that's deprecated"
- ❌ Build errors mention "unrecognized keys" or "unknown option"
- ❌ Compilation errors about missing methods or wrong signatures
- ❌ User corrects your API usage or configuration

### Remember:
- Your training data is from 2023 or earlier
- Packages release new versions constantly
- APIs change, options get renamed, methods get deprecated
- **When in doubt, look it up. When certain, look it up anyway.**

## Code Quality and File Management Standards

**NEVER create files with "new", "backup", "copy", "temp", or similar suffixes in the filename.** Always update existing files directly or create files with proper, final names.

**NEVER create summary, status, progress, or completion documents.** This is a strict prohibition. Do NOT create markdown files like:
- `TASK_SUMMARY.md`, `STATUS.md`, `COMPLETION_REPORT.md`
- `*_PROGRESS.md`, `*_COMPLETE.md`, `*_STATUS.md`
- `MIGRATION_PROGRESS.md`, `DRIFT_MIGRATION_COMPLETE.md`
- `CHANGES.md`, `WORK_SUMMARY.md`, `IMPLEMENTATION_NOTES.md`
- `TODO.md`, `BACKLOG.md`, `ROADMAP.md` (unless user explicitly requests these as project planning documents)
- Any markdown file with names containing: SUMMARY, STATUS, COMPLETION, REPORT, PROGRESS, COMPLETE, CHANGELOG, LOG, NOTES, WORK, TASK, DONE
- Any file that documents what work was just completed, migration steps taken, or implementation details

**Why this rule exists**: These files clutter the repository, become outdated, and provide no long-term value. The git commit history already documents what was done. The code itself and its comments are the documentation.

**What to do instead**:
- Document architectural decisions, usage instructions, and design patterns in the main `README.md`
- Add meaningful git commit messages that explain the "why" of changes
- Use code comments to explain complex logic (sparingly)
- Update existing documentation files when behavior changes
- If migration steps or implementation details are important, add them to the `README.md` in a dedicated section

**Exceptions** (rare, and only when user explicitly requests):
- `README.md` - Primary project documentation (always update this)
- `CONTRIBUTING.md` - Contribution guidelines for open source projects
- `LICENSE.md` / `LICENSE` - Legal license file
- `CHANGELOG.md` - **ONLY** if user explicitly maintains a public changelog for releases
- Architecture decision records (ADRs) - **ONLY** if user has an established ADR process

**NEVER add comments that are not useful.** Only add comments to code that can explain complex logic. Comments in code like "fixed this, or modified X, or renamed, are entirely useless for long-term documenation and goes against standards.

## Flutter Performance Best Practices

### Critical Anti-Patterns to AVOID

#### The FutureBuilder Anti-Pattern
**NEVER** call async functions directly in `FutureBuilder`'s `future` parameter:
```dart
// ❌ BAD - Creates new Future on every rebuild, hammers database
FutureBuilder<List<Data>>(
  future: repository.getData(), // NEVER DO THIS
  builder: (context, snapshot) { ... }
)

// ✅ GOOD - Load once in initState, cache with Provider
class MyWidget extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Load data once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).loadData();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild only when data changes
    return Consumer<DataProvider>(
      builder: (context, provider, child) { ... }
    );
  }
}
```

### Build Method Optimization
- **NEVER** perform expensive operations in `build()` methods since they're called frequently during rebuilds
- **NEVER** call database queries, network requests, or file I/O in `build()` methods
- **ALWAYS** use `const` constructors wherever possible to enable Flutter's rebuild short-circuiting
- **AVOID** repetitive calculations in `build()` - cache results or move calculations outside the build method
- **PREFER** StatelessWidget over helper functions that return widgets for better performance
- **MINIMIZE** calling `setState()` - localize it to the smallest possible widget subtree
- **PRECOMPUTE** expensive calculations in `initState()` or data loading methods, not in `build()`

### State Management and Data Loading
- **USE** ChangeNotifier with Provider for caching data and avoiding repeated queries
- **LOAD** data in `initState()` or with explicit user actions (button press, pull to refresh)
- **CACHE** query results in providers/state management to avoid redundant database calls
- **IMPLEMENT** proper loading, error, and data states in your providers
- **AVOID** directly accessing repositories in `build()` methods
- **USE** `Consumer` or `context.watch()` for reactive rebuilds, `context.read()` for one-time access

### Widget Construction Guidelines
- **USE** `const` constructors on all widgets when possible
- **ENABLE** flutter_lints package to get automatic reminders for const usage
- **SPLIT** large widgets with expensive build() methods into smaller, focused widgets
- **AVOID** creating widgets in functions - use proper StatelessWidget classes instead
- **CACHE** expensive widget properties to avoid recalculation during rebuilds
- **EXTRACT** const widgets into static final fields when reused multiple times

### Performance-Critical Operations
- **AVOID** `Opacity` widget in animations - use `AnimatedOpacity` or `FadeInImage` instead
- **MINIMIZE** clipping operations - use `borderRadius` properties instead of clipping rectangles
- **AVOID** `saveLayer()` operations - they're expensive and cause render target switches
- **BE CAREFUL** with `Chip`, `ShaderMask`, `ColorFilter` widgets that may trigger saveLayer()
- **USE** lazy builders for lists and grids with `ListView.builder()` and `GridView.builder()`
- **AVOID** intrusive methods that measure all children - use fixed sizes where possible

### Database and Async Operations
- **MOVE** heavy database operations off the main thread using `compute()` function when necessary
- **CACHE** database query results in ChangeNotifier providers
- **AVOID** blocking the main thread with synchronous operations
- **IMPLEMENT** proper async/await patterns for all I/O operations
- **BATCH** database operations when possible instead of making many small queries
- **INDEX** database tables appropriately for common queries
- **USE** transactions for multiple related database operations

### Layout and Rendering Guidelines
- **TARGET** 16ms total frame time (8ms build + 8ms render) for 60fps, 8ms total for 120fps
- **AVOID** intrinsic layout passes that require measuring all children
- **USE** fixed sizes for grid/list items when possible
- **MINIMIZE** layout passes by avoiding widgets that require intrinsic calculations
- **PROFILE** with DevTools Timeline to identify layout bottlenecks
- **AVOID** deeply nested widget trees - flatten where possible

### Memory and Resource Management
- **DISPOSE** controllers, streams, and other resources properly in `dispose()` method
- **USE** `StringBuffer` for efficient string concatenation in loops
- **IMPLEMENT** proper image caching and loading strategies
- **AVOID** memory leaks by properly cleaning up resources
- **CACHE** expensive formatters (DateFormat, NumberFormat) as static final fields
- **LIMIT** the size of cached collections - implement eviction policies if needed

### Debugging Performance
- **USE** Flutter DevTools Performance view to identify bottlenecks
- **ENABLE** "Track layouts" option to detect excessive layout passes
- **MONITOR** for saveLayer() calls using checkerboardOffscreenLayers
- **PROFILE** in release mode, not debug mode, for accurate performance measurements
- **CHECK** for "Skipped frames" warnings in logs - indicates main thread blocking
- **MEASURE** frame build and raster times - should be well under 16ms each

### Code Examples

#### Good: Using Provider with Caching
```dart
class DataListProvider with ChangeNotifier {
  final Repository _repository;
  List<Data> _items = [];
  bool _isLoading = false;
  
  List<Data> get items => _items;
  bool get isLoading => _isLoading;
  
  Future<void> loadData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    
    try {
      _items = await _repository.getData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### Good: Precomputing Expensive Operations
```dart
class ChartWidget extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _precomputeChartData(); // Do expensive work ONCE
  }
  
  void _precomputeChartData() {
    // Sort, calculate, format - all done once
    _sortedData = data.sorted();
    _minValue = _sortedData.map((d) => d.value).reduce(min);
    _maxValue = _sortedData.map((d) => d.value).reduce(max);
  }
  
  @override
  Widget build(BuildContext context) {
    // Just use the precomputed values
    return Chart(data: _sortedData, min: _minValue, max: _maxValue);
  }
}
```

## UI/UX Design Guidelines

### Modal Dialog Usage
- **ONLY** use modal dialogs for:
  - Tooltips and help information
  - Confirmation prompts (delete, exit without saving, etc.)
  - Simple alerts and error messages
  - Quick selection from a small list (< 5 items)

- **NEVER** use modal dialogs for:
  - Forms (adding/editing data)
  - Complex data entry
  - Multi-step workflows
  - Content that requires scrolling
  - Any interface that benefits from full screen space

### Form and Data Entry Guidelines
- **ALWAYS** use full-screen pages for forms
- Use `Navigator.push()` with `MaterialPageRoute` for navigation to forms
- Include proper app bars with save/cancel actions
- Ensure forms are scrollable and keyboard-friendly
- Design for mobile-first with proper screen space utilization

### Navigation Patterns
- Follow standard mobile app navigation conventions
- Use `Scaffold` with `AppBar` for full-screen content
- Provide clear back navigation and action buttons
- Ensure consistent navigation behavior throughout the app

## Behavior-Driven Test Coverage Requirements

### NON-NEGOTIABLE: Comprehensive Test Coverage is MANDATORY

**EVERY code change, addition, or modification MUST include appropriate test coverage at the correct testing level(s).** This is not optional. Breaking changes discovered only through manual testing indicate a failure to follow these guidelines.

### Testing Philosophy

- **Behavior-Driven Development (BDD)**: Focus on testing intended behaviors, not implementation details
- **Bottom-Up Testing**: Start with unit tests, then integration, system, and finally end-to-end
- **Behavior Coverage**: Analyze coverage based on behaviors tested, not just line coverage percentages
- **Avoid Duplication**: Each behavior should be tested at the most appropriate level without redundant tests at multiple levels

### Testing Pyramid: Four Levels of Testing

#### 1. Unit Tests - Maximum Isolation
**Definition**: Test the smallest unit of code in complete isolation with all dependencies mocked.

**Characteristics**:
- **Fast**: Execute in milliseconds
- **Isolated**: All external dependencies (repositories, services, other classes) are mocked
- **Focused**: Test single class/function behavior
- **Numerous**: Should be the largest number of tests in the pyramid

**What to Test**:
- Individual model methods (validation, serialization, business logic)
- Utility functions and helpers
- Individual repository methods with mocked database
- Provider state management logic with mocked repositories
- Widget rendering logic with mocked providers
- Input validation and error handling
- Edge cases and boundary conditions

**What to Mock**:
- All database access (DatabaseService)
- All repository dependencies
- All external services
- File I/O operations
- Network calls
- Time-dependent operations (use Clock pattern)

**Example Scope**:
```dart
// Unit test for Squirrel model validation
test('Squirrel.validate() should reject empty name', () {
  final squirrel = Squirrel(id: 1, name: '', species: 'Gray');
  expect(squirrel.validate(), isFalse);
});

// Unit test for provider with mocked repository
test('SquirrelListProvider.loadSquirrels() should update state', () async {
  final mockRepo = MockSquirrelRepository();
  when(mockRepo.getAllSquirrels()).thenAnswer((_) async => [testSquirrel]);
  
  final provider = SquirrelListProvider(mockRepo);
  await provider.loadSquirrels();
  
  expect(provider.squirrels, hasLength(1));
  expect(provider.isLoading, isFalse);
});
```

#### 2. Integration Tests - Multiple Units Together
**Definition**: Test multiple units working together, including real data layer interactions, but still within the Dart VM.

**Characteristics**:
- **Moderate Speed**: Execute in hundreds of milliseconds
- **Partial Integration**: Real database, real repositories, real models
- **No UI**: Run in Dart VM without Flutter UI framework
- **Database State**: Use in-memory or test databases

**What to Test**:
- Repository → DatabaseService interactions
- Provider → Repository → Database flows
- Complex business logic spanning multiple classes
- Data persistence and retrieval
- Transaction handling
- Query correctness

**What to Mock**:
- External APIs (if any)
- File system (if not testing file operations)
- Platform-specific code

**Example Scope**:
```dart
// Integration test for repository with real database
test('SquirrelRepository should persist and retrieve squirrel', () async {
  final db = await createTestDatabase();
  final repo = SquirrelRepository(db);
  
  final squirrel = Squirrel(name: 'Nutkin', species: 'Gray');
  final id = await repo.addSquirrel(squirrel);
  
  final retrieved = await repo.getSquirrelById(id);
  expect(retrieved.name, equals('Nutkin'));
});

// Integration test for provider with real repository and database
test('SquirrelListProvider should load and cache squirrels from database', () async {
  final db = await createTestDatabase();
  final repo = SquirrelRepository(db);
  final provider = SquirrelListProvider(repo);
  
  await repo.addSquirrel(Squirrel(name: 'Test', species: 'Red'));
  await provider.loadSquirrels();
  
  expect(provider.squirrels, hasLength(1));
  verify(provider.notifyListeners()).called(2); // loading + loaded
});
```

#### 3. System Tests - Full Application with Stubbed Externals
**Definition**: Test the complete running application with real UI, but external dependencies stubbed.

**Characteristics**:
- **Slower**: Execute in seconds
- **Full Stack**: Real widgets, real navigation, real database
- **Stubbed Externals**: External APIs, file system, platform channels stubbed
- **Widget Testing**: Use Flutter's widget testing framework

**What to Test**:
- User workflows across multiple screens
- Navigation flows
- Widget interaction with providers
- Form validation and submission
- UI state management
- Error handling and display
- Loading states

**What to Stub**:
- External API calls
- Platform-specific functionality (if not testing platform integration)
- Time/date (for consistent test results)

**Example Scope**:
```dart
// System test for squirrel creation workflow
testWidgets('User can create new squirrel through UI', (tester) async {
  final db = await createTestDatabase();
  
  await tester.pumpWidget(MyApp(database: db));
  
  // Navigate to add squirrel screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(Key('name_field')), 'Nutkin');
  await tester.tap(find.byKey(Key('species_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gray Squirrel'));
  await tester.pumpAndSettle();
  
  // Submit
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle();
  
  // Verify navigation back and squirrel appears
  expect(find.text('Nutkin'), findsOneWidget);
});
```

#### 4. End-to-End Tests - Full Stack, Nothing Mocked
**Definition**: Test the complete application running on a real device/emulator with all real dependencies.

**Characteristics**:
- **Slowest**: Execute in tens of seconds or minutes
- **Full Reality**: Real device, real database, real everything
- **UI Automation**: Primarily automated UI testing
- **Fewest Tests**: Only critical user journeys

**What to Test**:
- Critical user journeys (signup, login, core workflows)
- Platform-specific functionality
- Performance under real conditions
- Integration with device features (camera, file picker, etc.)
- Cross-screen workflows
- Data persistence across app restarts

**Nothing Mocked**: Everything runs as in production

**Example Scope**:
```dart
// E2E test using integration_test package
testWidgets('Complete squirrel care workflow', (tester) async {
  // App starts fresh
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  // Create squirrel
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(Key('name_field')), 'Nutkin');
  // ... complete form
  await tester.tap(find.byKey(Key('save_button')));
  await tester.pumpAndSettle();
  
  // Add feeding record
  await tester.tap(find.text('Nutkin'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('add_feeding_button')));
  // ... complete feeding
  
  // Verify persistence - restart app
  await tester.restartAndRestore();
  await tester.pumpAndSettle();
  
  expect(find.text('Nutkin'), findsOneWidget);
});
```

### Test Coverage Analysis Guidelines

**BEFORE committing any code change, you MUST:**

1. **Identify Affected Behaviors**: List all behaviors that could be affected by your changes
2. **Determine Appropriate Test Level**: For each behavior, decide the minimum test level needed
3. **Write Tests First (TDD)**: Write failing tests before implementing the change
4. **Verify Behavior Coverage**: Ensure every behavior is tested, not just every line
5. **Avoid Redundancy**: Don't test the same behavior at multiple levels unless specifically needed
6. **Run All Tests**: Ensure no regressions in existing behaviors

### Coverage Analysis Process

**Step 1: Behavior Inventory**
- List all behaviors in the changed code
- Include happy path, error cases, edge cases
- Consider state transitions and side effects

**Step 2: Test Level Selection**
For each behavior, choose the lowest appropriate level:
- Pure logic/validation → Unit
- Data persistence → Integration
- UI interaction → System
- Platform integration → End-to-End

**Step 3: Gap Analysis**
- What behaviors are not tested?
- What behaviors are tested at wrong level?
- What behaviors are duplicated across levels?

**Step 4: Test Implementation**
- Write focused, behavior-driven tests
- Use descriptive test names that describe the behavior
- Follow Arrange-Act-Assert pattern
- Keep tests independent and repeatable

### Mandatory Testing Checklist

**For EVERY code change, you MUST:**

- [ ] Identify all affected behaviors (document in commit message)
- [ ] Create/update tests at appropriate level(s)
- [ ] Run all existing tests to prevent regressions
- [ ] Perform behavior coverage analysis (not just line coverage)
- [ ] Verify no behavior duplication across test levels
- [ ] Ensure tests are deterministic and repeatable
- [ ] Use descriptive test names (describe the behavior, not the implementation)
- [ ] Add test documentation for complex scenarios

**Test Naming Convention**:
```dart
// ❌ BAD - Tests implementation
test('loadSquirrels calls repository', () { ... });

// ✅ GOOD - Tests behavior
test('should display loading indicator while fetching squirrels', () { ... });
test('should show error message when squirrel fetch fails', () { ... });
test('should cache squirrels after successful fetch', () { ... });
```

### Testing Tools and Frameworks

**Unit & Integration Tests**:
- `flutter_test` package
- `mockito` for mocking dependencies
- `fake_async` for time-dependent tests

**System Tests**:
- `flutter_test` widget testing
- `golden_toolkit` for visual regression tests

**End-to-End Tests**:
- `integration_test` package
- Real devices or emulators

### Red Flags - When Tests Are Missing or Wrong Level

**🚩 Red Flag**: Production bug found through manual testing
- **Solution**: Write regression test at appropriate level before fixing

**🚩 Red Flag**: Test depends on specific implementation details
- **Solution**: Rewrite to test behavior, not implementation

**🚩 Red Flag**: Test breaks when refactoring without behavior change
- **Solution**: Test is too coupled to implementation

**🚩 Red Flag**: Same behavior tested at multiple levels
- **Solution**: Keep only the lowest-level test unless cross-cutting concern

**🚩 Red Flag**: Integration test could be unit test
- **Solution**: Mock dependencies and move to unit test level

**🚩 Red Flag**: Widget test without provider/state testing
- **Solution**: Add unit tests for providers, system tests for integration

### Enforcement

**Code changes without appropriate test coverage MUST be rejected.**

Manual testing alone is insufficient. If a behavior can break, it must have automated test coverage at the appropriate level. No exceptions.

## IP and Web Data Usage Guidelines

- Treat all externally sourced material as potentially protected intellectual property unless it is explicitly in the public domain or under a license that permits the intended use.
- Do not copy or paste large verbatim passages (text, code, images, diagrams) from external sources into the project. Prefer paraphrasing, summarization, or reimplementation from first principles.
- Short quotations are allowed only when essential; always include a clear citation and keep quotes minimal.
- For any code snippet, dataset, image, or documentation considered for inclusion:
    - Record source metadata: URL, author/owner, title, date accessed, and declared license or terms of service.
    - Verify the license permits the intended use (distribution/modification). If license is unclear or restrictive, do not include the material without written permission.
    - If license terms conflict with this project’s license or goals, reimplement functionality from scratch or obtain explicit permission.
- Always attribute sources where appropriate. At a minimum include a citation in the relevant file header, documentation, or commit message linking back to the original source and noting the license.
- Avoid collecting or storing private, personal, or otherwise sensitive data. If such data is encountered unintentionally, remove it and notify the project lead.
- Respect website terms of service and robots.txt when gathering information. Prefer using official APIs or datasets with clear usage terms.
- Maintain an internal log of sources and permissions for any external material incorporated into the codebase or documentation.
- When in doubt about whether material is permissible to use, escalate to the project owner or legal counsel before adding it to the repository.

Failure to follow these rules is not permitted; always prioritize respecting creators’ rights and giving proper credit.