# AI Character Generation & Conversation System - Project Summary

## Project Overview

This project is an AI character generation and conversation system that creates AI characters based on user responses to questions and simulates conversations between these characters. The system consists of a Python-based backend API (Flask) and a Flutter-based frontend application.

## System Architecture

```
Project/
├── backend_ai/           # Python Flask API server
│   ├── main.py          # Main API endpoints
│   ├── openai_client.py # OpenAI API client configuration
│   ├── module/          # AI modules for character generation and conversation
│   ├── prompt/          # Prompt templates for AI
│   ├── data/            # Generated character data storage
│   ├── rag/             # Retrieval Augmented Generation components
│   └── requirements.txt # Python dependencies
└── flutter_app/         # Flutter mobile application
    ├── lib/            # Dart source code
    │   ├── config/     # App configuration (router)
    │   ├── models/     # Data models
    │   ├── screens/    # UI screens
    │   ├── services/   # API and storage services
    │   └── widgets/    # Reusable UI components
    ├── pubspec.yaml    # Flutter dependencies
    └── platforms/      # iOS/Android/Web configurations
```

## Backend AI (Python Flask)

### Key Endpoints

- `POST /generate_character`: Generates an AI character from user responses
- `POST /ai_chat`: Simulates a conversation between two AI characters
- `POST /ai_conversation`: Alternative endpoint for AI character conversations

### Core Functionality

1. **Character Generation Process**
   - Receives user responses to 9 questions about their complexes and concerns
   - Uses OpenAI GPT-4.1-mini to extract core philosophy from responses
   - Generates character settings based on extracted philosophy
   - Creates conversation data for the character
   - Creates a vector store and uploads character data for retrieval

2. **AI Conversation Simulation**
   - Alternates conversation between two characters
   - Uses vector search to reflect character personalities
   - Manages conversation history for natural dialogue
   - Formats events in 5W1H structure (who, what, when, where, why, how)

### Technical Stack

- **Framework**: Flask + Flask-CORS
- **AI API**: OpenAI GPT-4.1-mini, GPT-4o
- **Data Storage**: Text files + Vector Store
- **Environment Management**: python-dotenv

### Module Structure

- `generate_character_settings.py`: Creates character profiles
- `generate_character_conversation.py`: Generates sample conversations
- `extract_core_philosophy.py`: Extracts core beliefs from user responses
- `vector_store.py`: Manages vector database operations
- `ai_chat.py`: Handles AI conversation between characters
- `utils.py`: Utility functions
- `get_next_character_index.py`: Manages character indexing

## Flutter App (Frontend)

### Screen Structure

- **Home**: Main screen with navigation to other features
- **Journal (A.dart)**: 5W1H input + emotion parameters
- **Cafe (B.dart)**: Chat functionality with AI characters
- **Library**: Library screen for saved content
- **Settings (C.dart)**: App settings
- **Complex Form**: Detailed questionnaire (9 questions about complexes)

### Core Functionality

1. **Form Input System**
   - Basic information input (what, where, when, why, who, how)
   - Emotion sliders (joy, anger, sadness, pleasure)
   - Complex questionnaire (9 detailed questions)

2. **AI Integration**
   - HTTP communication with backend API
   - Character generation request handling
   - Display and management of generated results

3. **Navigation**
   - GoRouter for routing
   - Shell navigation (tab switching)
   - Smooth screen transitions

### Technical Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: StatefulWidget
- **Routing**: go_router
- **HTTP Communication**: http package
- **Data Persistence**: shared_preferences

### Key Components

- `Person` model: Represents characters with position, color, messages, and AI data
- `AIService`: Handles API communication with the backend
- `AIConversationDialog`: UI component for character conversations
- `LocalStorage`: Manages local data persistence

## Data Flow

```
1. User Input Collection:
   a.dart (5W1H + emotions) → complex_form.dart (9 questions)

2. Character Generation:
   AIService.generateCharacter() → backend_ai/generate_character API
   → GPT-4.1-mini processing → Vector Store upload

3. Character Interaction:
   b.dart (Cafe screen) → AI character interaction
   → ai_conversation_dialog.dart displays conversation
```

## File Storage Structure

- Character data: `backend_ai/data/character/{index}/`
- Settings files: `settings.txt`, `conversation.txt`, `philosophy.txt`

## Setup Instructions

### Backend AI Setup

1. **Python Environment Setup**
```bash
cd backend_ai
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. **Environment Variables**
```bash
# Create .env file
echo "OPENAI_API_KEY=your_openai_api_key_here" > .env
```

3. **Server Launch**
```bash
python main.py
# Server runs on http://localhost:5001
```

### Flutter App Setup

1. **Flutter Environment Setup**
```bash
cd flutter_app
flutter pub get
```

2. **Run the App**
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Web
flutter run -d web
```

## API Specifications

### POST /generate_character

Generates an AI character from user responses.

**Request Example:**
```json
{
  "q1_answer": "I worry about my complex",
  "q2_answer": "I compare myself to others",
  "q3_answer": "Started feeling this way in school",
  // ... up to q9_answer
}
```

**Response Example:**
```json
{
  "character_settings": "Generated character settings",
  "conversation_data": "Character conversation data",
  "vector_store_id": "vs_12345...",
  "status": "success"
}
```

### POST /ai_chat

Initiates a conversation between characters.

**Request Example:**
```json
{
  "vector_store_id": ["vs_id_1", "vs_id_2"],
  "event": {
    "when": "This morning",
    "where": "University classroom",
    "who": "Professor and me",
    "what": "Got scolded by the professor",
    "why": "Because I was watching YouTube during class",
    "how": "Lightly warned in front of everyone"
  }
}
```

## Development & Operations

### Required Environment Variables
- `OPENAI_API_KEY`: OpenAI API key

### Port Settings
- Backend: localhost:5001
- Flutter (development): localhost:3000 (Web)

## License

Private project - not for public distribution.