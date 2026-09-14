import { mkdir, writeFile } from "node:fs/promises";
import { basename, join } from "node:path";
import { CONFIG_DIR_NAME, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Entry = {
	type: string;
	customType?: string;
	data?: { enabled?: boolean };
	message?: { role?: string; content?: unknown };
};

const readOnlyCommand = /^(?:git\s+(?:status|diff|log|show|branch)\b|(?:rg|grep|find|ls|pwd|cat|head|tail)\b)/;
const shellSyntax = /[;|&><`$()]/;

function messageText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.filter((block): block is { type: string; text: string } =>
			typeof block === "object" && block !== null && block.type === "text" && typeof block.text === "string",
		)
		.map((block) => block.text)
		.join("\n");
}

function planFileName(name: string): string {
	const safe = basename(name.trim().toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""));
	return `${safe || `plan-${new Date().toISOString().slice(0, 10)}`}.md`;
}

export default function (pi: ExtensionAPI) {
	let enabled = false;
	let toolsBeforePlan: string[] | undefined;
	let latestPlan = "";

	function setPlanMode(next: boolean) {
		if (next === enabled) return;
		enabled = next;
		if (enabled) {
			toolsBeforePlan = pi.getActiveTools();
			pi.setActiveTools(toolsBeforePlan.filter((tool) => tool !== "edit" && tool !== "write"));
		} else if (toolsBeforePlan) {
			pi.setActiveTools(toolsBeforePlan);
			toolsBeforePlan = undefined;
		}
		pi.appendEntry("plan-mode-state", { enabled });
	}

	pi.registerCommand("plan", {
		description: "Start or stop read-only planning: /plan [topic], /plan off",
		handler: async (args, ctx) => {
			const topic = args.trim();
			if (topic === "off") {
				setPlanMode(false);
				ctx.ui.notify("Plan mode off. Editing restored.", "info");
				return;
			}

			setPlanMode(true);
			ctx.ui.notify("Plan mode on. Editing is blocked; use /save-plan when ready.", "info");
			if (topic) {
				pi.sendUserMessage(`Plan this work: ${topic}`);
			}
		},
	});

	pi.registerCommand("save-plan", {
		description: "Save the latest plan to .pi/plans/[name].md",
		handler: async (args, ctx) => {
			if (!latestPlan) {
				ctx.ui.notify("No plan found yet. Ask for a numbered Plan: first.", "warning");
				return;
			}
			const file = join(ctx.cwd, CONFIG_DIR_NAME, "plans", planFileName(args));
			await mkdir(join(ctx.cwd, CONFIG_DIR_NAME, "plans"), { recursive: true });
			await writeFile(file, `# ${args.trim() || "Plan"}\n\n${latestPlan.trim()}\n`);
			ctx.ui.notify(`Saved ${file.slice(ctx.cwd.length + 1)}`, "info");
		},
	});

	pi.on("tool_call", (event) => {
		if (!enabled || event.toolName !== "bash") return;
		const command = String(event.input.command ?? "").trim();
		if (!readOnlyCommand.test(command) || shellSyntax.test(command)) {
			return { block: true, reason: "Plan mode permits only a single read-only shell command. Use /plan off to edit." };
		}
	});

	pi.on("before_agent_start", () => {
		if (!enabled) return;
		return {
			message: {
				customType: "plan-mode-instructions",
				content: "Plan mode is active. Inspect only; do not modify files. End planning responses with a `Plan:` heading and a numbered, implementation-ready list. Discuss and revise the plan until the user asks to save or execute it.",
				display: false,
			},
		};
	});

	pi.on("message_end", (event) => {
		if (event.message.role !== "assistant") return;
		const text = messageText(event.message.content);
		if (/^\s*Plan:/im.test(text)) latestPlan = text;
	});

	pi.on("session_start", (_event, ctx) => {
		const entries = ctx.sessionManager.getEntries() as Entry[];
		const state = entries.filter((entry) => entry.type === "custom" && entry.customType === "plan-mode-state").pop();
		enabled = state?.data?.enabled ?? false;
		for (const entry of entries) {
			if (entry.message?.role === "assistant") {
				const text = messageText(entry.message.content);
				if (/^\s*Plan:/im.test(text)) latestPlan = text;
			}
		}
		if (enabled) {
			toolsBeforePlan = pi.getActiveTools();
			pi.setActiveTools(toolsBeforePlan.filter((tool) => tool !== "edit" && tool !== "write"));
		}
	});
}
