# Urban City Hub - Relay Control Dashboard Design Guidelines

## Design Approach

**Selected Approach**: Hybrid - Industrial Dashboard System with Urban Theme
- Primary inspiration: Control room interfaces, smart city dashboards, industrial monitoring systems
- Visual reference: Cyberpunk-inspired urban control panels with functional clarity
- Design system foundation: Carbon Design System (IBM) adapted for industrial/monitoring contexts
- Theme: Modern urban infrastructure control - think traffic control centers, power grid monitoring

## Typography System

**Font Families** (via Google Fonts CDN):
- Primary: 'Inter' - Clean, technical, excellent for data/labels (weights: 400, 500, 600, 700)
- Accent: 'JetBrains Mono' - Monospaced font for GPIO pins, API endpoints, technical data (weights: 400, 600)

**Type Scale**:
- Page Title: text-4xl font-bold (Dashboard header)
- Section Headers: text-2xl font-semibold
- Card Titles: text-lg font-semibold
- GPIO Pin Labels: text-xl font-mono font-semibold (JetBrains Mono)
- Body Text: text-base font-medium
- Status Labels: text-sm font-medium uppercase tracking-wide
- Technical Data: text-sm font-mono (API endpoints, timestamps)

## Layout System

**Spacing Primitives**: Tailwind units of 4, 6, 8, 12, 16
- Component padding: p-6 or p-8
- Card gaps: gap-6 or gap-8
- Section spacing: space-y-8 or space-y-12
- Container padding: px-6 md:px-12

**Grid Structure**:
- Dashboard container: max-w-7xl mx-auto px-6
- Main relay control grid: 2x2 grid on desktop (grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6)
- Sidebar/Control panel: Single column on mobile, side panel on desktop
- Master controls: Full-width bar above relay grid

**Layout Hierarchy**:
1. Fixed header bar (h-16) - Logo, "HubCity Control", connection status
2. Control panel section (py-8) - Master ON/OFF controls, API configuration
3. Relay grid section (py-12) - 4 relay cards in 2x2 grid
4. Status footer (h-12) - System info, last updated timestamp

## Component Library

### 1. Header Bar
- Fixed position at top, full-width
- Height: h-16
- Contains: Logo/icon (left), "HubCity Control" title (center-left), connection indicator (right)
- Connection indicator: Small circle with "Connected" or "Disconnected" label, pulsing animation when active

### 2. Relay Control Cards (Primary Component)
**Structure** (Each card represents one GPIO relay):
- Border with subtle glow effect when active
- Padding: p-8
- Border radius: rounded-xl
- Shadow: shadow-lg when active, shadow-md when inactive

**Card Layout**:
- Top section: GPIO pin number in large monospace font (text-3xl font-mono font-bold) with "GPIO" label
- Middle section: Relay name/label (editable or "Relay 1-4") text-xl font-semibold
- Status badge: Pill-shaped badge showing "ACTIVE" or "INACTIVE" (uppercase, tracking-wide)
- Toggle switch: Large, prominent switch component (h-12 w-24) with smooth animation
- Bottom section: Last action timestamp (text-xs font-mono)

### 3. Master Control Panel
- Full-width bar above relay grid
- Contains two prominent action buttons side-by-side
- Button specs: px-12 py-4 text-lg font-semibold rounded-lg
- "ALL ON" button (left) and "ALL OFF" button (right)
- Spacing between buttons: gap-6

### 4. API Configuration Panel
**Collapsible card** (starts collapsed, expandable):
- Header: "API Configuration" with expand/collapse icon
- Content when expanded:
  - API endpoint input field (full-width, font-mono)
  - Connection test button
  - Status indicator showing last successful connection
  - Auto-refresh toggle switch with interval selector

### 5. Toggle Switch Component
**Specifications**:
- Size: w-20 h-10 (large, easy to click)
- Sliding circle indicator: h-8 w-8
- Smooth transition: transition-all duration-300
- Clear ON/OFF positions with ample travel distance
- Include haptic-style animation on state change

### 6. Status Indicator
**Visual states**:
- Active state: Pulsing animation (subtle, 2s cycle)
- Inactive state: Static, muted appearance
- Transition state: Smooth fade between states (300ms)
- Error state: Attention-grabbing indicator

## Interaction Patterns

### Relay Control Flow
1. User clicks toggle switch on relay card
2. Switch animates to new position (300ms smooth)
3. API call initiated, loading state shown (optional spinner on switch)
4. Card background subtly glows when active
5. Status badge updates with fade transition
6. Timestamp updates at bottom of card

### Master Control Flow
1. User clicks "ALL ON" or "ALL OFF"
2. Brief confirmation (visual feedback on button)
3. All relay cards update sequentially with stagger effect (100ms delay between each)
4. Success notification appears briefly

### Error Handling
- Failed API calls show error toast notification (top-right corner)
- Relay card shows error state with retry button
- Connection status indicator in header turns to error state

## Visual Effects (Minimal & Purposeful)

**Allowed Animations**:
1. Toggle switch slide: 300ms ease-in-out
2. Active relay glow: Subtle pulsing (2s cycle, low opacity)
3. Connection status pulse: When connected, gentle pulse every 3s
4. Card state transitions: Fade effects for status changes (200ms)
5. Sequential cascade: When using master controls, cards update with 100ms stagger

**No animations for**:
- Page load
- Scrolling effects
- Background movements
- Decorative elements

## Accessibility

- Toggle switches: Include hidden text labels for screen readers
- Keyboard navigation: Full support with visible focus states
- ARIA labels: All interactive elements properly labeled
- Color-independent status: Use icons + text + patterns, not just color
- High contrast ratios: Ensure all text meets WCAG AA standards
- Touch targets: Minimum 44px × 44px for all interactive elements

## Images

**Background Elements** (Subtle, non-distracting):
- Hero section: NO large hero image - this is a dashboard, not a landing page
- Background texture: Optional subtle circuit board pattern or urban grid pattern at very low opacity (5-10%) on page background only
- Icon set: Use Heroicons (outline style) via CDN for all UI icons (power, settings, connection, etc.)
- No decorative images - purely functional interface

**Image Specifications**:
- If background texture used: Tile seamlessly, very low opacity, dark urban/tech theme
- All icons: 24px × 24px standard size, use larger (32px) for relay card status indicators

## Responsive Behavior

**Desktop (lg: 1024px+)**:
- 2×2 relay grid
- Sidebar for API configuration (if needed)
- Full master control panel visible

**Tablet (md: 768px)**:
- 2×2 relay grid (slightly smaller cards)
- API config moves to collapsible panel
- Master controls remain full-width

**Mobile (base: <768px)**:
- Single column relay cards (grid-cols-1)
- Stacked master control buttons (full-width each)
- Compact header with hamburger menu for settings

## Technical Implementation Notes

- Use fetch API for REST calls to FastAPI backend
- Implement polling for status updates (every 2-5 seconds configurable)
- Store API endpoint in localStorage
- Add connection retry logic with exponential backoff
- Include CORS handling for cross-origin requests