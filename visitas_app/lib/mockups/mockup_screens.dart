import 'package:flutter/material.dart';

class MockupsIndexScreen extends StatelessWidget {
  const MockupsIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      (
        title: 'Splash / bienvenida',
        subtitle: 'Pantalla de entrada con branding',
        screen: const MockupSplashScreen(),
      ),
      (
        title: 'Inicio de sesión',
        subtitle: 'Acceso con credenciales',
        screen: const MockupLoginScreen(),
      ),
      (
        title: 'Dashboard / home',
        subtitle: 'Resumen diario y accesos',
        screen: const MockupDashboardScreen(),
      ),
      (
        title: 'Listado de visitas',
        subtitle: 'Agenda comercial del día',
        screen: const MockupVisitsListScreen(),
      ),
      (
        title: 'Detalle de visita',
        subtitle: 'Estado, datos y notas',
        screen: const MockupVisitDetailScreen(),
      ),
      (
        title: 'Crear / editar visita',
        subtitle: 'Formulario de gestión',
        screen: const MockupVisitFormScreen(),
      ),
      (
        title: 'Perfil / configuración',
        subtitle: 'Cuenta y preferencias',
        screen: const MockupProfileScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mockups principales')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: screens.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = screens[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text('${index + 1}'),
              ),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.screen),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MockupSplashScreen extends StatelessWidget {
  const MockupSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2f66ff), Color(0xff6cb8ff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 90, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Visitas Comerciales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Planifica, visita y registra',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MockupLoginScreen()),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class MockupLoginScreen extends StatelessWidget {
  const MockupLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Iniciar sesión',
      body: [
        _SectionCard(
          child: Column(
            children: [
              _MockInput(label: 'Correo electrónico', icon: Icons.mail_outline),
              const SizedBox(height: 12),
              _MockInput(label: 'Contraseña', icon: Icons.lock_outline),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MockupDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MockupDashboardScreen extends StatelessWidget {
  const MockupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Dashboard',
      body: [
        const _SectionCard(
          child: Row(
            children: [
              Expanded(child: _KpiCard(label: 'Visitas hoy', value: '8')),
              SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'Completadas', value: '5')),
            ],
          ),
        ),
        const _SectionCard(
          title: 'Accesos rápidos',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickAction(icon: Icons.list_alt, label: 'Mis visitas'),
              _QuickAction(icon: Icons.add_location_alt, label: 'Nueva visita'),
              _QuickAction(icon: Icons.person_outline, label: 'Perfil'),
            ],
          ),
        ),
      ],
    );
  }
}

class MockupVisitsListScreen extends StatelessWidget {
  const MockupVisitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Listado de visitas',
      body: [
        _SectionCard(
          title: 'Visitas previstas',
          child: Column(
            children: const [
              _VisitListTile(
                client: 'Clínica San Miguel',
                address: 'Av. Mesa y López, 12',
                status: 'Pendiente',
              ),
              Divider(height: 20),
              _VisitListTile(
                client: 'Farmacia Central',
                address: 'C/ León y Castillo, 4',
                status: 'En curso',
              ),
              Divider(height: 20),
              _VisitListTile(
                client: 'Distribuciones Nexo',
                address: 'Pol. Industrial El Sebadal',
                status: 'Finalizada',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MockupVisitDetailScreen extends StatelessWidget {
  const MockupVisitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Detalle de visita',
      body: const [
        _SectionCard(
          title: 'Cliente',
          child: Text('Clínica San Miguel · Responsable: Marta Pérez'),
        ),
        _SectionCard(
          title: 'Resumen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: 30/06/2026'),
              SizedBox(height: 6),
              Text('Hora: 11:30'),
              SizedBox(height: 6),
              Text('Estado: En curso'),
              SizedBox(height: 6),
              Text('Objetivo: Presentación de nueva línea de productos'),
            ],
          ),
        ),
        _SectionCard(
          title: 'Notas',
          child: Text(
            'Placeholder: cliente interesado en piloto de 2 semanas y '
            'solicita propuesta económica.',
          ),
        ),
      ],
    );
  }
}

class MockupVisitFormScreen extends StatelessWidget {
  const MockupVisitFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Crear / editar visita',
      body: [
        _SectionCard(
          child: Column(
            children: const [
              _MockInput(label: 'Cliente', icon: Icons.business),
              SizedBox(height: 12),
              _MockInput(label: 'Fecha', icon: Icons.calendar_today),
              SizedBox(height: 12),
              _MockInput(label: 'Hora', icon: Icons.schedule),
              SizedBox(height: 12),
              _MockInput(label: 'Objetivo', icon: Icons.flag_outlined),
              SizedBox(height: 12),
              _MockInput(label: 'Notas', icon: Icons.edit_note),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar (mockup)'),
          ),
        ),
      ],
    );
  }
}

class MockupProfileScreen extends StatelessWidget {
  const MockupProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _MockupScaffold(
      title: 'Perfil y configuración',
      body: const [
        _SectionCard(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text('Lucía Ramírez'),
            subtitle: Text('comercial@empresa.com'),
          ),
        ),
        _SectionCard(
          title: 'Preferencias',
          child: Column(
            children: [
              SwitchListTile(
                value: true,
                onChanged: null,
                title: Text('Notificaciones de visitas'),
              ),
              Divider(height: 0),
              SwitchListTile(
                value: false,
                onChanged: null,
                title: Text('Modo oscuro'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MockupScaffold extends StatelessWidget {
  final String title;
  final List<Widget> body;

  const _MockupScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: body
            .map(
              (widget) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: widget,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _MockInput extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MockInput({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffeef3ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blue.shade700),
      label: Text(label),
      backgroundColor: const Color(0xffeff4ff),
      side: BorderSide(color: Colors.blue.shade50),
    );
  }
}

class _VisitListTile extends StatelessWidget {
  final String client;
  final String address;
  final String status;

  const _VisitListTile({
    required this.client,
    required this.address,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: const Icon(Icons.location_on_outlined),
      ),
      title: Text(client),
      subtitle: Text(address),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: status == 'Finalizada'
              ? Colors.green.shade50
              : status == 'En curso'
                  ? Colors.orange.shade50
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
