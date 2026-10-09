# SLA Rules (Momentum)

All rules live in `lib/services/sla_service.dart`. Screens never calculate SLA themselves.

## Status rules

| Status | Rule |
|---|---|
| Completed | Task status is Done |
| Overdue | Deadline has passed and the task is not Done |
| At Risk | Not Done and due in 48 hours or less |
| On Track | Everything else |

Checked in this order: Completed, then Overdue, then At Risk, then On Track.

## Why these choices

- **Deadline = end of the due day (23:59:59).** The date picker gives only a date. Without this, a task due today would be Overdue at 00:00 today.
- **48 hours.** Gives a team two working days to react. It is one constant (`atRiskHours`), so it can be changed in one place (for example to 24).
- **Done always wins.** A task finished late is Completed, not Overdue. Late finishes show up in the on-time rate instead.

## Time used and Work done

- **Time used** = time since created / time from created to deadline, capped at 0 to 100%. Calculated automatically.
- **Work done** = 0 to 100, set by the slider. Marking a task Done sets it to 100.
- **Project progress** = average Work done of all tasks (0% when there are no tasks).

## Statistics

- **On-time rate** = completed tasks finished by their deadline / all completed tasks (0% if none).
- **Workload** = open tasks per member: 0 to 2 Balanced, 3 to 4 Heavy, 5 or more Overloaded.
- **Needs attention** = At Risk and Overdue tasks, earliest deadline first.

## Edge cases handled

- No tasks: progress and on-time rate show 0% (no divide by zero).
- Task assigned to a member who no longer exists: shown as "Unassigned".
- Done task with no finish date (sample data): counted as on time.

## Tested (test/sla_service_test.dart)

Exactly 48 hours left, 48 hours plus 1 second, exactly at the deadline, 1 second past due, Done before and after the due date, 0% and 100% work done, empty task list, on-time rate, workload thresholds, needs-attention order and the SLA message text.
