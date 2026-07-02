# Routing rules

Use the safest route when context is ambiguous.

## Explicit personal signals

- “personal project”
- “side project”
- “life admin”
- personal Gmail/calendar/contact references
- personal GitHub username/repositories

Route to: `personal`

## Explicit work signals

- Linear ticket
- ClickUp ticket
- sprint, standup, manager, client, employer, company repo
- work Slack/email/calendar/doc references
- work organization GitHub/GitLab repositories

Route to: `work`

## Cross-context signals

- “Why did my day/week go sideways?”
- “What affected my focus?”
- “Compare personal and work priorities.”
- “What should I plan for tomorrow across everything?”

Route to: `insights`

## Ambiguous reads

If the user is asking for analysis and no external action is needed, route to `insights`.

## Ambiguous writes/actions

Ask which context should own the action. Do not guess.
