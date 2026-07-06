import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'state/app_session.dart';
import 'widgets/common_widgets.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/onboarding_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/trainer/trainer_home_screen.dart';
import 'screens/trainer/add_student_screen.dart';
import 'screens/trainer/upgrade_student_screen.dart';
import 'screens/trainer/my_students_screen.dart';
import 'screens/trainer/student_detail_screen.dart';
import 'screens/trainer/trainer_settings_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/course_detail_screen.dart';
import 'screens/student/cert_history_screen.dart';
import 'screens/student/student_settings_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const YPVApp());

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',              builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',    builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login',         builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/admin-login',   builder: (_, __) => const AdminLoginScreen()),
    GoRoute(path: '/admin/home',    builder: (_, __) => const AdminDashboardScreen()),

    // Trainer shell with bottom nav
    ShellRoute(
      builder: (ctx, state, child) => TrainerShell(child: child),
      routes: [
        GoRoute(path: '/trainer/home',     builder: (_, __) => const TrainerHomeScreen()),
        GoRoute(path: '/trainer/students', builder: (_, __) => const MyStudentsScreen()),
        GoRoute(path: '/trainer/settings', builder: (_, __) => const TrainerSettingsScreen()),
      ],
    ),

    // Trainer sub-pages (no shell nav)
    GoRoute(path: '/trainer/add-student',     builder: (_, __) => const AddStudentScreen()),
    GoRoute(path: '/trainer/upgrade-student', builder: (_, __) => const UpgradeStudentScreen()),
    GoRoute(
      path: '/trainer/student-detail/:id',
      builder: (_, state) => StudentDetailScreen(studentId: state.pathParameters['id']!),
    ),

    // Student shell with bottom nav
    ShellRoute(
      builder: (ctx, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(path: '/student/home',     builder: (_, __) => const StudentDashboardScreen()),
        GoRoute(path: '/student/certs',    builder: (_, __) => const CertHistoryScreen()),
        GoRoute(path: '/student/settings', builder: (_, __) => const StudentSettingsScreen()),
      ],
    ),

    // Student sub-pages
    GoRoute(
      path: '/student/course-detail/:index',
      builder: (_, state) => CourseDetailScreen(
          index: int.tryParse(state.pathParameters['index'] ?? '0') ?? 0),
    ),
  ],
);

class YPVApp extends StatelessWidget {
  const YPVApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppSession(),
    child: MaterialApp.router(
      title: 'Yoga Prana Vidya',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    ),
  );
}

// ── Trainer Shell ─────────────────────────────────────────────
class TrainerShell extends StatefulWidget {
  final Widget child;
  const TrainerShell({super.key, required this.child});
  @override State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  @override
  void initState() {
    super.initState();
    final session = context.read<AppSession>();
    if (session.trainer == null) {
      session.trainerLoading = true;
      Future.microtask(session.loadTrainerSession);
    }
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/trainer/students')) return 1;
    if (loc.startsWith('/trainer/settings'))  return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    final session = context.watch<AppSession>();
    return Scaffold(
      body: SessionGate(
        loading: session.trainerLoading && session.trainer == null,
        error: session.trainer == null ? session.trainerError : null,
        onRetry: () => session.loadTrainerSession(),
        child: widget.child,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF694CAB),
        onPressed: () => context.push('/trainer/add-student'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: Row(children: [
          _NavItem(icon: Icons.home_outlined,    label: 'Home',     selected: idx == 0, onTap: () => context.go('/trainer/home')),
          _NavItem(icon: Icons.people_outlined,  label: 'Students', selected: idx == 1, onTap: () => context.go('/trainer/students')),
          const SizedBox(width: 60),
          _NavItem(icon: Icons.person_outlined,  label: 'Profile',  selected: idx == 2, onTap: () => context.go('/trainer/settings')),
          const SizedBox(width: 48),
        ]),
      ),
    );
  }
}

// ── Student Shell ─────────────────────────────────────────────
class StudentShell extends StatefulWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});
  @override State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  @override
  void initState() {
    super.initState();
    final session = context.read<AppSession>();
    if (session.student == null) {
      session.studentLoading = true;
      Future.microtask(session.loadStudentSession);
    }
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/student/certs'))    return 1;
    if (loc.startsWith('/student/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    final session = context.watch<AppSession>();
    return Scaffold(
      body: SessionGate(
        loading: session.studentLoading && session.student == null,
        error: session.student == null ? session.studentError : null,
        onRetry: () => session.loadStudentSession(),
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) {
          const paths = ['/student/home', '/student/certs', '/student/settings'];
          context.go(paths[i]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_outlined), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined),      label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: selected ? const Color(0xFF694CAB) : const Color(0xFF8A8A9A), size: 22),
        Text(label, style: TextStyle(fontSize: 10, letterSpacing: 0.5,
            color: selected ? const Color(0xFF694CAB) : const Color(0xFF8A8A9A))),
      ]),
    ),
  );
}
