import { appendFile, mkdir, readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { matchesKey, Text } from "@earendil-works/pi-tui";

const usageDir = join(homedir(), ".pi", "agent", "usage");
const usageFile = join(usageDir, "events.jsonl");

type Totals = { input: number; output: number; cost: number; models: Map<string, Totals> };

function emptyTotals(): Totals {
	return { input: 0, output: 0, cost: 0, models: new Map() };
}

function add(totals: Totals, model: string, input: number, output: number, cost: number) {
	totals.input += input; totals.output += output; totals.cost += cost;
	const item = totals.models.get(model) ?? emptyTotals();
	item.input += input; item.output += output; item.cost += cost;
	totals.models.set(model, item);
}

function sessionTotals(ctx: ExtensionCommandContext): Totals {
	const totals = emptyTotals();
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const message = entry.message as AssistantMessage;
		add(totals, ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "unknown", message.usage.input || 0, message.usage.output || 0, message.usage.cost?.total || 0);
	}
	return totals;
}

async function allTotals(): Promise<Totals> {
	const totals = emptyTotals();
	try {
		for (const line of (await readFile(usageFile, "utf8")).split("\n")) {
			if (!line) continue;
			const row = JSON.parse(line) as { model: string; input: number; output: number; cost: number };
			add(totals, row.model, row.input || 0, row.output || 0, row.cost || 0);
		}
	} catch (error: unknown) {
		if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
	}
	return totals;
}

const format = (n: number) => n < 1000 ? String(n) : `${(n / 1000).toFixed(1)}k`;

function lines(title: string, totals: Totals): string[] {
	return [
		title,
		`Input:  ${format(totals.input)} tokens`,
		`Output: ${format(totals.output)} tokens`,
		`Cost:   $${totals.cost.toFixed(4)}`,
		...([...totals.models.entries()].map(([model, t]) => `${model}: ↑${format(t.input)} ↓${format(t.output)} $${t.cost.toFixed(4)}`)),
		"",
		"Quota: Codex has no public quota API. Claude API and Vertex quota need separate admin/cloud credentials.",
		"Esc or Enter closes",
	];
}

async function showUsage(ctx: ExtensionCommandContext) {
	const text = lines("Pi usage (all recorded sessions)", await allTotals()).join("\n");
	if (ctx.mode !== "tui") {
		ctx.ui.notify(text, "info");
		return;
	}
	await ctx.ui.custom((_tui, theme, _keys, done) => {
		const display = new Text(theme.fg("accent", text), 1, 1);
		return {
			render: (width) => display.render(width),
			invalidate: () => display.invalidate(),
			handleInput: (data) => { if (matchesKey(data, "escape") || matchesKey(data, "enter")) done(undefined); },
		};
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("message_end", async (event, ctx) => {
		if (event.message.role !== "assistant") return;
		const message = event.message as AssistantMessage;
		if (!message.usage) return;
		await mkdir(usageDir, { recursive: true });
		await appendFile(usageFile, `${JSON.stringify({ timestamp: new Date().toISOString(), session: ctx.sessionManager.getSessionId(), project: ctx.cwd, model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "unknown", input: message.usage.input || 0, output: message.usage.output || 0, cost: message.usage.cost?.total || 0 })}\n`);
	});

	pi.registerCommand("usage", {
		description: "Show global usage in the terminal; /usage pin or /usage unpin",
		handler: async (args, ctx) => {
			if (args.trim() === "pin") {
				const t = sessionTotals(ctx);
				ctx.ui.setWidget("pi-usage", [`${ctx.model?.id ?? "model"}: ↑${format(t.input)} ↓${format(t.output)} $${t.cost.toFixed(3)}`]);
				return;
			}
			if (args.trim() === "unpin") {
				ctx.ui.setWidget("pi-usage", undefined);
				return;
			}
			await showUsage(ctx);
		},
	});
}
