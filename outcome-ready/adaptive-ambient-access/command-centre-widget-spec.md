# Adaptive Ambient Access — Command Centre Widget Spec

**Project:** OR-AAA-001 | **Agent:** AAA-004 | **Target:** mcp-command-centre

## Widget: AmbientStatusWidget

### Purpose
Real-time ambient window and support delivery overview for coordinator view in the Command Centre dashboard.

### Data Sources
```typescript
// Bridge queries
const activeWindows = await bridgeSQL(`
  SELECT p.name, w.start_time, w.end_time, w.support_type, w.auto_connect
  FROM aaa_ambient_windows w
  JOIN aaa_participants p ON p.id = w.participant_id
  WHERE w.active = true
  ORDER BY w.start_time
`);

const recentLogs = await bridgeSQL(`
  SELECT p.name, l.initiated_at, l.ended_at, l.delivery_method
  FROM aaa_support_log l
  JOIN aaa_participants p ON p.id = l.participant_id
  WHERE l.initiated_at > now() - interval '24 hours'
  ORDER BY l.initiated_at DESC
  LIMIT 20
`);
```

### Component Structure
```tsx
<AmbientStatusWidget>
  <SummaryBar activeCount={n} todayCount={n} alertCount={n} />
  <ParticipantGrid>
    {participants.map(p => <ParticipantCard key={p.id} ambient={p.currentWindow} />)}
  </ParticipantGrid>
  <RecentActivity logs={recentLogs} />
</AmbientStatusWidget>
```

### Refresh
- Poll every 60s via `bridgeSQL`
- Alert badge if any participant has missed window (ended_at IS NULL AND end_time < now())

### File location
`src/components/widgets/AmbientStatusWidget.tsx`
