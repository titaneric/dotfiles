---
name: security-ticket-composer
description: Use when composing or creating Jira security tickets for LTL Security Promotion requests, including Flava ACL, egress proxy, WFPF/WF, ACLOS, and FLAVA_ACL_LTL tickets; includes QMD guidance for finding supporting docs.
metadata:
  language: en
  scope: tw-sre-security-ticket
---

# security-ticket-composer

Use this skill to draft or create LTL security Jira tickets for network access
requests. It provides a reusable ticket template, Jira defaults, and a workflow
for finding supporting documentation before filing the request.

## Default Jira Fields

Use these defaults when the user asks to create a ticket like an existing
`LTLSECPRO` security ticket:

| Field | Default |
|-------|---------|
| Project | `LTLSECPRO` |
| Issue type | `Task` |
| Priority | `Medium` |
| Labels | `FLAVA_ACL_LTL` |
| Reference issue pattern | `LTLSECPRO-388` |

If Jira creation fails with required custom fields, inspect the referenced issue
with `jira_get_issue(..., fields="*all")` and retry with only the required
field values that are relevant and non-sensitive. Do not guess hidden required
custom fields.

## Documentation Lookup

When a ticket needs references from Flava or Serve docs, use the existing docs
skills before finalizing the ticket:

1. Load `flava-serve-docs-qmd` for Flava/Serve doc lookup rules.
2. Load `qmd` for the search/get workflow.
3. Search `flava-docs` for Flava network, VPC, ACL, NLB, FEP, egress proxy,
   DNS, cert-manager, or related platform docs.
4. Retrieve full source pages with `qmd get` or `qmd multi-get` before citing.
5. Convert `qmd://flava-docs/<path>.md` to
   `https://flava-docs.workers-hub.com/<path>` by following the rendering rules
   in `flava-serve-docs-qmd`.

Prefer structured QMD queries instead of plain user text. Example:

```bash
qmd query -c flava-docs $'intent: Find Flava documentation supporting a security ticket for network ACL access.\nlex: Flava VPC Network ACL ACLOS NLB egress proxy frontend proxy FEP\nvec: documentation explaining source destination ports and network ACL requirements for Flava access requests'
```

Do not paste snippets into a ticket unless the full source page was retrieved.
Include only concise references in the `【Reference】` section.

## Title Pattern

Use a concrete title. Prefer including the team, environment/cluster, platform,
and access type.

```text
SRE <purpose> 在 <platform/env> 需允許 <source> -> <destination> <access-type>
```

Examples:

```text
SRE 搭建selini (serve dev) cluster 在 flava環境需允許FEP -> NLB network ACL
SRE 搭建lenini (serve prod) cluster 在 flava環境需允許FEP -> NLB network ACL
SRE 搭建內部 cert-manager 在 flava環境需連 let's encrypt endpoint & cloudflare-dns（Egress Proxy rules)
```

## Description Template

Use raw Jira markup unless the user explicitly requests Markdown conversion.

```text
【申請背景與目的】
TW SRE 團隊需申請 <source> 至 <destination> 的 <access-type>，目的為 <business-or-operational-purpose>。
WF: [<wfpf-url>]

【開通期限】
期間：永久
永久原因：
- <why-permanent-access-is-required>
- 若連線規則過期，<impact-if-expired>。

【資料等級】
內部使用

【來源與目的地】
來源：
- <source-system-or-aclos>

目的地：
- <destination-host-or-service>

通訊協定與 Port：
- <protocol>/<port>

【Reference】
- <supporting-doc-url>
```

## Flava ACL Notes

- Identify source, destination, protocol, port, environment, and whether access
  is permanent or time-limited.
- For ACLOS requests, write the exact ACLOS names in `【來源與目的地】`.
- For Flava NLB/VPC Network ACL requests, cite the relevant Flava docs found via
  QMD rather than relying on memory.
- Avoid over-scoping: only list destinations and ports that are needed.

## Workflow

1. Ask for or infer these inputs:
   - WFPF/WF URL
   - Environment or cluster
   - Source and destination
   - Protocol and ports
   - Duration and reason
   - Data classification
   - Supporting docs or keywords to search
2. Draft title and description first when the user asks only for text.
3. For Flava/Serve requests, run the documentation lookup workflow and add the
   best supporting URLs to `【Reference】`.
4. If the user asks to create Jira, use `jira_create_issue` with:
   - `project_key = "LTLSECPRO"`
   - `issue_type = "Task"`
   - `additional_fields = {"priority":{"name":"Medium"},"labels":["FLAVA_ACL_LTL"]}`
5. If copying an existing ticket, inspect it first for project, type, priority,
   labels, and any relevant non-null custom fields.
6. After creation, return the Jira key/URL plus the final title and a short
   summary of fields used.

## Example: FEP To Public NLB

Use only as an example, not as the default for every ticket.

```text
【申請背景與目的】
TW SRE 團隊需申請 FEP（Frontend Proxy）至 Flava NLB 的 VPC Network ACL，讓 FEP 可連線到 <cluster> 的 public NLB origin，以支援 FEP 對外流量導入服務。
WF: [<wfpf-url>]

【開通期限】
期間：永久
永久原因：
- FEP 為服務對外入口，需持續轉送外部使用者流量至後端 NLB origin。
- ACL 若過期將導致 FEP 無法連線到 NLB，服務入口流量會中斷。

【資料等級】
內部使用

【來源與目的地】
來源：
- FEP ACLOS
- <dev-or-prod-fep-aclos>

目的地：
- <cluster> traefik-public NLB VIP

通訊協定與 Port：
- TCP/80
- TCP/443

【Reference】
- <Flava FEP/NLB doc URL found through QMD>
```
