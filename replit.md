# HubCity Control - Urban Relay Management Dashboard

## Overview
HubCity Control is a modern, urban-themed dashboard for controlling Raspberry Pi GPIO relays via REST API. The application provides real-time monitoring and control of relay states through an elegant web interface with industrial aesthetics.

## Purpose
This application serves as a web-based control panel for managing GPIO relays on a Raspberry Pi running a FastAPI backend. It allows operators to:
- Configure connection to external FastAPI relay controller
- Control individual GPIO relays (pins 17, 27, 22, 23)
- Use master controls for simultaneous relay operations
- Monitor real-time connection status and relay states
- Auto-refresh relay status at configurable intervals

## Project Architecture

### Frontend (React + TypeScript)
- **Framework**: React with Vite
- **Routing**: Wouter for client-side routing
- **State Management**: TanStack Query for server state
- **UI Components**: Shadcn UI with Radix primitives
- **Styling**: Tailwind CSS with custom urban theme
- **Theme**: Dark mode by default with light mode toggle

### Backend (Express + TypeScript)
- **Framework**: Express.js
- **Storage**: In-memory storage for relay state caching
- **API**: Proxy layer to external FastAPI controller
- **Validation**: Zod for runtime type validation

### Key Features
1. **Relay Control Cards**: Individual cards for each GPIO pin with visual status indicators
2. **Master Controls**: Bulk operations to activate/deactivate all relays
3. **API Configuration**: Runtime configuration of FastAPI endpoint
4. **Connection Status**: Real-time monitoring of API connectivity
5. **Auto-Refresh**: Configurable polling intervals (2-30 seconds)
6. **Theme Toggle**: Dark/light mode support
7. **Responsive Design**: Mobile-first responsive layout

## Recent Changes
- **2025-01-27**: Initial implementation with complete relay control system
  - Created schema-first architecture with TypeScript types
  - Built urban-themed UI components following design guidelines
  - Implemented backend proxy API for FastAPI communication
  - Added runtime API endpoint configuration
  - Integrated real-time status monitoring
  - Fixed critical issues with endpoint propagation and connection status

## Technical Stack
- **Languages**: TypeScript, React, Node.js
- **UI Library**: Shadcn UI + Radix UI
- **Styling**: Tailwind CSS
- **State**: TanStack Query v5
- **Validation**: Zod
- **Icons**: Lucide React
- **Fonts**: Inter (UI), JetBrains Mono (technical data)

## Data Models

### Relay Schema
```typescript
{
  gpio: number;        // GPIO pin number (17, 27, 22, 23)
  name: string;        // Display name (e.g., "Relay 1")
  state: "on" | "off"; // Current state
  lastUpdated?: string; // Last update timestamp
}
```

### API Configuration
```typescript
{
  endpoint: string;          // FastAPI URL (e.g., "http://raspberrypi.local:8000")
  autoRefresh: boolean;      // Enable/disable polling
  refreshInterval: number;   // Milliseconds (2000-30000)
}
```

## API Endpoints

### Backend Routes
- `GET /api/relays` - Get all relay states
- `GET /api/status` - Test connection to external API
- `GET /api/config/endpoint` - Get current API endpoint
- `POST /api/config/endpoint` - Update API endpoint
- `POST /api/relay` - Control individual relay
- `POST /api/relay/all_on` - Activate all relays
- `POST /api/relay/all_off` - Deactivate all relays

### External FastAPI Routes (Expected)
- `GET /` - Root endpoint returning `{message, pins}`
- `POST /relay` - Control relay `{gpio: number, state: "on"|"off"}`
- `POST /relay/all_on` - Activate all relays
- `POST /relay/all_off` - Deactivate all relays

## User Preferences
- **Default Theme**: Dark mode (urban/industrial aesthetic)
- **Auto-Refresh**: Configurable, user-controlled
- **Coding Style**: TypeScript strict mode, functional components, modern React patterns
- **Design System**: Follows design_guidelines.md religiously

## Design Guidelines
The application strictly follows the design guidelines in `design_guidelines.md`:
- Urban city theme with industrial dashboard aesthetics
- Dark grays with neon blue accents
- JetBrains Mono for technical data (GPIO pins, endpoints)
- Inter for UI text
- Subtle animations and transitions
- Accessibility-first approach
- Responsive grid layouts

## How to Use

### 1. Start the Application
The application is configured to run automatically:
```bash
npm run dev
```

### 2. Configure API Endpoint
1. Open the dashboard
2. Click "API Configuration" to expand the panel
3. Enter your FastAPI endpoint (e.g., `http://192.168.1.100:8000`)
4. Configure auto-refresh settings if desired
5. Click "Save Configuration"
6. Click "Test Connection" to verify

### 3. Control Relays
- **Individual Control**: Use the switch on each relay card
- **Master Controls**: Use "ALL ON" or "ALL OFF" buttons
- **Monitor Status**: Watch the connection indicator and relay states

### 4. Auto-Refresh
- Enable "Auto-Refresh Status" in API Configuration
- Select refresh interval (2, 5, 10, or 30 seconds)
- The dashboard will poll the API automatically

## Environment Variables
- `RELAY_API_ENDPOINT` (optional): Default FastAPI endpoint URL
- Can be overridden at runtime via the dashboard

## Development Notes
- Frontend runs on port 5000 (Vite dev server)
- Backend Express server also on port 5000 (same process)
- No separate CORS configuration needed (same origin)
- LocalStorage used for client-side preferences
- In-memory storage for server-side relay state cache

## Known Limitations
- API endpoint configuration persists only in memory (resets on server restart)
- Relay state is cached locally (requires polling for real-time updates)
- No authentication/authorization (intended for local network use)
- Assumes FastAPI follows the expected route structure

## Future Enhancements (Not in MVP)
- Relay scheduling and timer functionality
- Activity logging and state history
- Custom relay naming and grouping
- Persistent database storage
- User authentication
- Mobile app version
