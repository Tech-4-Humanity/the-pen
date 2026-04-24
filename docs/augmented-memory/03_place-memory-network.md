# Place Memory Network

## Principle
Places can hold multiple layers of memory. Users can attach memories privately or publicly. The system signals memory presence without overwhelming the user.

## Core Behaviour
- user enters location
- system checks place graph
- system checks user memories
- system checks network density
- system surfaces subtle signal

## Signals
- this place has memories
- you have been here before
- people remember this place

## Place Object
- id
- name
- type (cemetery, cafe, street, school, park, etc)
- coordinates (point or polygon)
- memory count
- curated flag

## Memory to Place
- memory_id
- place_id
- visibility
- created_at

## Discovery
- map view
- list view
- trails
- search

## Physical Anchors
- QR
- NFC
- printed
- partner-installed markers

## Rule
Start virtual-first. Add physical only where value increases.
