// Run by the linear mod through `kit exec`: the team's open issues, grouped by status.
const states = await linear.query_workflowStates({ first: 50, filter: { team: { key: { eq: input.team } }, type: { in: ["triage", "backlog", "unstarted", "started"] } } });
const lists = await Promise.all(states.nodes.map((s) => linear.query_issues({ first: 50, filter: { state: { id: { eq: s.id } } }, orderBy: "updatedAt" })));
return {
  team: input.team,
  groups: states.nodes.map((s, n) => ({
    name: s.name, type: s.type, color: s.color, position: s.position,
    issues: lists[n].nodes.map((i) => ({ id: i.identifier, title: i.title, priority: i.priority, url: i.url, branch: i.branchName, updated: i.updatedAt })),
  })),
};
