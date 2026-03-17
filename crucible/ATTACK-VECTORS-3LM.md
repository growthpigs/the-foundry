# CRUCIBLE FINDINGS — Attack Vectors Found in Specs Produced by The Foundry

## Context
These are real vulnerabilities found in a Functional Specification Document (FSD) for a field service management app (3LM/LifeModo). The FSD was produced by the Foundry pipeline — autonomous AI agents following the command files. Every vulnerability below represents a FAILURE of the Foundry's instructions to catch the issue.

The question is: WHY did the Foundry's instructions fail to catch these? What's missing from the command files?

---

## ATTACK VECTOR 1 — PowerSync & Offline Sync Data Loss (GAP-SP2)

### The Vulnerability
When two technicians update the exact same ticket simultaneously on poor mobile connections, the system experiences unrecoverable data loss and potentially severe database deadlocks.

### Specific Failures:
1. **RLS Data Erasure Trap**: If Tech A is working offline and the dispatcher reassigns the ticket to Tech B (who also goes offline), when both reconnect, Tech A's offline edits are silently discarded because RLS blocks the upload (assigned_technician_id no longer matches). The system's V1 behavior is to "Discard" failed offline edits with only a UI toast notification.

2. **Version Trigger Race Condition**: The auto_increment_version_tickets trigger fires BEFORE UPDATE to increment version, but the upload_signed_work_order RPC explicitly tries to force version=6 manually. This dual-write causes constraint violations or unexpected version jumps, breaking Optimistic Concurrency Control.

3. **Server Wins OCC is Blindly Destructive**: If Tech A and Tech B mutate the exact same field (e.g., both change status), the system's strategy is "Server version wins" — Tech B's update is entirely overwritten with no manual merge queue.

4. **MAX+1 vs Sequence Contradiction**: The spec says the trigger uses Postgres sequences (nextval), but the Failure Modes Table claims MAX+1 with row-level locking. Under concurrent sync storms, MAX+1 causes severe database contention and deadlocks.

### Why The Foundry Failed to Catch This:
- The FSD command file has no "Concurrent Actor Analysis" requirement
- The user-stories command asks about "network timeouts" but NOT about "two actors modifying the same entity simultaneously while offline"
- The red-team-spec command checks completeness and contradiction but has NO adversarial concurrency scenarios
- The explore command's code-architect agent is never told to analyze concurrent modification patterns

---

## ATTACK VECTOR 2 — Auth & RLS Security (Storage Bucket Exploit)

### The Vulnerability
A malicious authenticated technician can bypass security to overwrite or orphan another technician's photos. Storage RLS policies only check bucket_id and role, NOT ticket ownership.

### Specific Exploits:
1. **Cross-Ticket Overwrite**: Technician A bypasses the UI and sends a direct API call to upload a file at Technician B's ticket path. Storage RLS allows it because it only checks role, not ticket ownership.

2. **Silent Deletion (SWO Blocker)**: If DELETE policy also relies only on bucket_id and role, Technician A can delete Technician B's photos. The database still points to the deleted file, causing 404 errors.

3. **Orphan Bomb (Storage Exhaustion DoS)**: A malicious user uploads gigabytes of garbage directly to storage buckets via the API, never calling the database RPC. Files become orphans with no DB records. Storage quota exhausted, blocking ALL legitimate uploads.

### Why The Foundry Failed to Catch This:
- The FSD command file has NO requirement to map authorization boundaries across system layers (DB vs Storage vs API)
- The red-team command's agents (code-reviewer, silent-failure-hunter, pr-test-analyzer) are ALL code-level tools — none analyze authorization model consistency
- The user-stories command asks about "cross-tenant leak" but NOT about "what if a user bypasses the UI and hits the API directly"
- The explore command never tells agents to trace permission models across layers

---

## ATTACK VECTOR 3 — Logic Dead-Ends (State Machine Failures)

### The Vulnerability
The ticket state machine has dead-ends where tickets get stuck or the system crashes.

### Specific Dead-Ends:
1. **Escalation Overlay Death**: A ticket can reach "closed" while a safety escalation remains permanently open. No constraint prevents this.

2. **Reassignment + Escalation Visibility**: When a ticket is reassigned, the escalation is hard-linked to the original technician. The new technician inherits the ticket with ZERO visibility into the open safety escalation.

3. **SWO Rejection Fatal Dead-End**: The system skips swo_uploaded and jumps to awaiting_validation. On rejection, the spec says "set status to swo_uploaded" — but the H5 trigger blocks awaiting_validation → swo_uploaded as invalid. Result: dispatcher cannot reject an SWO without crashing the backend.

4. **Reverse Transition Gap**: The H5 matrix defines forward transitions but many reverse transitions are undefined, creating dead states.

### Why The Foundry Failed to Catch This:
- The FSD command file has NO requirement to trace state machines backward (reverse transitions)
- The red-team-spec command checks "Does any FR contradict another FR?" but NOT "Does the state machine have dead-ends?"
- The user-stories command asks about failure scenarios but NOT about "what happens if this action needs to be UNDONE?"
- No stage in the pipeline forces the AI to walk every state machine path forward AND backward

---

## META-ANALYSIS: Foundry Instruction Gaps

### Gap Category 1: No Adversarial Security Checklist in FSD
The FSD has 12 sections. None force the AI to verify authorization boundaries across system layers.

### Gap Category 2: No Concurrent Actor Analysis
No stage forces "what happens when two actors modify the same entity simultaneously?"

### Gap Category 3: No State Machine Reverse Trace
No stage forces "for every transition, is the reverse defined? What are the dead-ends?"

### Gap Category 4: No "Bypass the UI" Test
No stage forces "what if a malicious user bypasses the frontend and hits the API directly?"

### Gap Category 5: Red Team is Code-Level, Not Architecture-Level
The red-team agents (code-reviewer, silent-failure-hunter, pr-test-analyzer) are all code-level. None analyze architectural authorization consistency or state machine completeness.

### Gap Category 6: Chronological Order Questions
- Should the red-team-spec run BEFORE the FSD is committed, not after?
- Should there be a mandatory "state machine analysis" step between explore and FSD?
- Should there be a security-specific exploration step for multi-layer systems?
