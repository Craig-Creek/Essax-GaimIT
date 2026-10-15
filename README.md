# Essax

Think together. Build together. Compete together.

Essax is a community platform designed for people who want to collaborate, exchange ideas, form teams, and participate in competitions. It brings discussions, team collaboration, and competitive opportunities into one focused experience.

Built with Flutter, Essax aims to make collaboration accessible through a distinctive interface, a consistent visual identity, and an experience designed around communities and shared goals.

---

About Essax

Great ideas become more powerful when people work on them together.

Essax is being developed to help users discover competitions, connect with like-minded people, participate in discussions, and build teams around shared interests and ambitions.

The goal is to create a platform where ideas can move beyond conversations into collaborative projects and meaningful results.

Core Features

🏠 Home

A central place to discover featured competitions, explore recent discussions, and find teams worth joining.

🏆 Competitions

Explore challenges and competitive opportunities, discover their requirements, and work toward participating individually or as a team.

💬 Discussions

Share ideas, ask questions, exchange knowledge, and engage with the community through conversations.

👥 Teams

Discover collaborative groups, connect with other members, and build teams around common goals.

🎨 A Distinctive Experience

Essax uses a warm, dark visual identity with espresso-toned surfaces, burnt-orange accents, muted olive details, and cream typography.

The interface is designed to feel intentional and recognizable rather than like a default application template.

---

Development Status

Status: Early development

Essax is actively being developed. The current application establishes the initial interface and navigation for the platform.

Component| Status
Four-tab navigation| Initial implementation
Home interface| Initial implementation
Competition discovery UI| Sample content
Discussion interface| Sample content
Teams interface| Sample content
User accounts and authentication| Planned
Persistent discussions| Planned
Image and video sharing| Planned
Competition applications| Planned
Team creation and membership| Planned
Backend integration| Planned

Some current screens use demonstration content. Features listed as planned are not yet represented as fully operational services.

Technology Stack

- Flutter — cross-platform application development
- Dart — application programming language
- NovaSP — Essax's designated typeface
- Codemagic — automated Android build workflow
- GitHub — source control and project collaboration

Getting Started

Requirements

Install the following tools before building Essax locally:

- Flutter SDK
- Dart SDK compatible with your Flutter installation
- Git
- An Android development environment or connected build service

Installation

Clone the repository:

git clone https://github.com/Craig-Creek/Essax-GaimIT.git

Enter the project directory:

cd Essax-GaimIT

Install dependencies:

flutter pub get

Run the application:

flutter run

Build an Android APK

To create a release APK locally:

flutter build apk --release

The generated APK will be available at:

build/app/outputs/flutter-apk/app-release.apk

Essax also includes a Codemagic workflow for automated Android release builds.

Project Structure

Essax-GaimIT/
├── .github/
│   └── dependabot.yml
├── assets/
│   └── fonts/
│       └── NovaSP_GaimIT_GaimIT_LLC.ttf
├── lib/
│   └── main.dart
├── codemagic.yaml
├── pubspec.yaml
└── README.md

The current interface is consolidated in "lib/main.dart". Additional screens, models, services, and backend integrations can be separated into dedicated files as the project grows.

Project Vision

Essax is being built around four connected ideas:

1. Discover — find challenges, opportunities, and ideas worth exploring.
2. Discuss — exchange knowledge and develop ideas through conversation.
3. Collaborate — form teams and work toward shared objectives.
4. Compete — turn preparation and teamwork into participation and achievement.

These principles guide the platform's development as it grows beyond its initial interface.

Contributing

Essax is a developing project, and improvements to its design, functionality, accessibility, reliability, and documentation are valuable.

Before proposing substantial changes:

1. Review the existing implementation.
2. Keep the four primary navigation areas consistent.
3. Follow the established Essax visual identity.
4. Test changes before submitting them.
5. Clearly document incomplete features and external service requirements.

Roadmap

- [ ] Establish a stable application foundation
- [ ] Complete the four primary screens
- [ ] Introduce user authentication and profiles
- [ ] Implement team creation and membership
- [ ] Add persistent community discussions
- [ ] Support image and video sharing
- [ ] Implement competition applications and participation
- [ ] Integrate backend services and data storage
- [ ] Improve testing, accessibility, and release automation

License

A license has not yet been specified. Unless a license is added to this repository, reuse and redistribution remain subject to applicable copyright law.

---

Essax — ideas are the beginning. Collaboration takes them further.