# Email read access

This starter supports multiple email accounts by treating each mailbox as a separate named source.

Recommended source names:

```text
personal_primary
personal_projects
personal_finance
work_primary
```

The `personal` profile may read all sources whose scope is `personal`. The `work` profile may read only work sources. The `insights` profile should read Markdown summaries, not raw mailboxes, by default.

## Multiple personal accounts

Configure multiple personal accounts in local config using the shape from [`config/accounts.example.yaml`](../config/accounts.example.yaml):

```yaml
accounts:
  personal_email_accounts:
    scope: personal
    access: read_only
    accounts:
      - id: personal_primary
        type: gmail
        account_label: personal@example.com
      - id: personal_projects
        type: gmail_or_outlook_or_imap
        account_label: projects@example.com
```

Use stable account IDs in summaries and source pointers:

```text
personal_primary:thread:abc123
personal_projects:message:def456
```

This prevents two accounts from mixing similarly named senders, threads, or projects.

## Read-only policy

Allowed operations:

- search
- list threads/messages
- read message/thread content
- export a message for summarization, if needed

Denied operations:

- send/reply/forward
- archive/delete/move
- mark read/unread
- label or flag changes
- unsubscribe or filter changes

## Practical Hermes email paths

Hermes can reach email through different integrations. Choose the least-powerful option that works for your setup.

### Option A: IMAP-only mail client source

Use an IMAP-capable CLI/tool such as Hermes' bundled Himalaya email skill with one named account per mailbox.

For read-only startup:

1. Configure only IMAP for each account.
2. Do not configure SMTP/send settings.
3. Store account credentials in your local password manager or Hermes secrets, not in this repo.
4. Allow only list/search/read commands in agent instructions.

Example account names:

```toml
[accounts.personal_primary]
email = "personal@example.com"
# IMAP backend only

[accounts.personal_projects]
email = "projects@example.com"
# IMAP backend only

[accounts.work_primary]
email = "you@company.com"
# IMAP backend only
```

Important caveat: IMAP credentials often still technically allow mailbox mutations such as moving or flagging messages. The starter blocks those at the policy/instruction level, but a true provider-enforced read-only OAuth scope is stronger when available.

See [`config/himalaya.example.toml`](../config/himalaya.example.toml) for a multi-account IMAP-only example.

#### Gmail IMAP checklist

For each Gmail or Google Workspace inbox:

1. Enable IMAP in Gmail settings.
2. Create an app password or approved mailbox credential for this machine.
3. Add one `[accounts.<id>]` block to your local Himalaya config.
4. Configure only `backend.*` IMAP settings.
5. Do not configure `message.send.*` SMTP settings.
6. Verify the account can list/read messages.
7. Do not grant the agent permission to run move/delete/flag/send commands.

Allowed command shapes:

```bash
himalaya --account personal_primary envelope list
himalaya --account personal_primary message read <message-id>
himalaya --account personal_projects envelope list
himalaya --account personal_projects message read <message-id>
```

Denied command shapes:

```bash
himalaya template send
himalaya message write
himalaya message reply
himalaya message move
himalaya message delete
himalaya flag add
himalaya flag remove
```

### Option B: Gmail/Workspace OAuth read-only

If you use a Gmail/Google Workspace integration, request only Gmail read-only scopes when possible:

```text
https://www.googleapis.com/auth/gmail.readonly
```

Do not grant send or modify scopes for this starter phase.

Avoid scopes like:

```text
https://www.googleapis.com/auth/gmail.send
https://www.googleapis.com/auth/gmail.modify
```

If you use an MCP or custom Gmail tool, expose only read/search/get tools to Hermes. Do not expose send, modify, trash, label, or mark-read tools during the starter phase.

### Option C: Dedicated Hermes mailbox

You can also give Hermes its own mailbox for people to email the agent. That is useful as a messaging gateway, but it is not the same as read-only access to your personal or work inboxes.

Do not use a dedicated Hermes mailbox as a shortcut for your actual personal/work inboxes. It is a communication inbox for the agent, not background awareness over your mail.

## Personal radar behavior

The personal email radar should:

1. Load all configured `personal` email sources.
2. Process each source separately.
3. Store summaries under `memory/personal/**`.
4. Include the account ID in every source pointer.
5. Avoid raw full email bodies by default.

Example summary:

```md
## Needs attention

### Travel booking changed
- Source: personal_primary / airline@example.com / 2026-07-02 / thread abc123
- Summary: Flight time changed by 45 minutes.
- Suggested action: Check calendar impact.
- Confidence: high

### Side project reply
- Source: personal_projects / collaborator@example.com / 2026-07-02 / thread def456
- Summary: Collaborator sent feedback on the landing page draft.
- Suggested action: Review before the weekend.
- Confidence: medium
```

## Verification prompts

After configuring accounts, test:

```text
Personal profile: Which personal email accounts are configured?
Personal profile: Summarize personal email radar without taking actions.
Work profile: Summarize personal_primary. Expected: refuse.
Insights profile: What changed today? Expected: read Markdown summaries only.
```
