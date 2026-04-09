import { StringEnum, Type } from "@mariozechner/pi-ai";
import { defineTool, type ExtensionAPI } from "@mariozechner/pi-coding-agent";

type ExaSearchResponse = {
	results?: Array<{
		title?: string;
		url?: string;
		publishedDate?: string;
		text?: string;
		highlights?: string[];
		author?: string;
		score?: number;
	}>;
};

type ExaContentsResponse = {
	results?: Array<{
		title?: string;
		url?: string;
		text?: string;
		highlights?: string[];
		publishedDate?: string;
	}>;
};

const SEARCH_TYPES = ["fast", "auto", "deep", "deep-reasoning"] as const;
const SEARCH_CATEGORIES = ["company", "news", "research paper", "people"] as const;
const CONTENT_TYPES = ["text", "highlights", "none"] as const;

function getApiKey() {
	const apiKey = process.env.EXA_API_KEY?.trim();
	if (!apiKey) {
		throw new Error("EXA_API_KEY is not set. Add it to your shell env (for example fish/include/ignore/extra.fish) and restart pi.");
	}
	return apiKey;
}

async function exaRequest<T>(path: string, body: Record<string, unknown>, signal?: AbortSignal): Promise<T> {
	const response = await fetch(`https://api.exa.ai${path}`, {
		method: "POST",
		headers: {
			"content-type": "application/json",
			"x-api-key": getApiKey(),
		},
		body: JSON.stringify(body),
		signal,
	});

	if (!response.ok) {
		const text = await response.text();
		throw new Error(`Exa API request failed (${response.status} ${response.statusText}): ${text.slice(0, 1000)}`);
	}

	return (await response.json()) as T;
}

function truncate(text: string, maxLength: number) {
	if (text.length <= maxLength) return text;
	return `${text.slice(0, maxLength - 1)}…`;
}

function renderSearchResults(results: NonNullable<ExaSearchResponse["results"]>) {
	if (results.length === 0) return "No results.";

	return results
		.map((result, index) => {
			const title = result.title?.trim() || "Untitled";
			const url = result.url?.trim() || "";
			const date = result.publishedDate ? `\nPublished: ${result.publishedDate}` : "";
			const author = result.author ? `\nAuthor: ${result.author}` : "";
			const score = typeof result.score === "number" ? `\nScore: ${result.score}` : "";
			const highlights = result.highlights?.length
				? `\nHighlights:\n${result.highlights.map((h) => `- ${truncate(h.replace(/\s+/g, " ").trim(), 400)}`).join("\n")}`
				: "";
			const text = result.text?.trim()
				? `\nText:\n${truncate(result.text.replace(/\s+/g, " ").trim(), 1200)}`
				: "";

			return `${index + 1}. ${title}\nURL: ${url}${date}${author}${score}${highlights}${text}`;
		})
		.join("\n\n");
}

function renderContentsResults(results: NonNullable<ExaContentsResponse["results"]>) {
	if (results.length === 0) return "No contents returned.";

	return results
		.map((result, index) => {
			const title = result.title?.trim() || "Untitled";
			const url = result.url?.trim() || "";
			const date = result.publishedDate ? `\nPublished: ${result.publishedDate}` : "";
			const highlights = result.highlights?.length
				? `\nHighlights:\n${result.highlights.map((h) => `- ${truncate(h.replace(/\s+/g, " ").trim(), 400)}`).join("\n")}`
				: "";
			const text = result.text?.trim()
				? `\nText:\n${truncate(result.text.replace(/\s+/g, " ").trim(), 2000)}`
				: "";

			return `${index + 1}. ${title}\nURL: ${url}${date}${highlights}${text}`;
		})
		.join("\n\n");
}

const exaSearchTool = defineTool({
	name: "exa_search",
	label: "Exa Search",
	description: "Search the web with Exa and optionally return extracted page text or highlights.",
	promptGuidelines: [
		"Use this for current web research, docs lookup, API references, code examples, news, people, company, or research-paper discovery.",
		"Prefer contentType 'highlights' when you only need snippets. Prefer 'text' when you need more contiguous source content.",
		"Use category only when you specifically want people, company, news, or research paper results.",
	],
	parameters: Type.Object({
		query: Type.String({ description: "Search query" }),
		type: Type.Optional(StringEnum(SEARCH_TYPES, { description: "Search type. auto is usually best." })),
		category: Type.Optional(StringEnum(SEARCH_CATEGORIES, { description: "Optional category filter." })),
		numResults: Type.Optional(Type.Number({ minimum: 1, maximum: 25, description: "Number of results to return. Default 5." })),
		contentType: Type.Optional(StringEnum(CONTENT_TYPES, { description: "text, highlights, or none. Default text." })),
		maxCharacters: Type.Optional(Type.Number({ minimum: 500, maximum: 50000, description: "Max extracted characters per result when using text/highlights. Default 10000." })),
		includeDomains: Type.Optional(Type.Array(Type.String(), { description: "Optional domains to include, e.g. ['docs.exa.ai', 'github.com']" })),
		excludeDomains: Type.Optional(Type.Array(Type.String(), { description: "Optional domains to exclude." })),
		maxAgeHours: Type.Optional(Type.Number({ description: "Freshness threshold in hours. 0 forces livecrawl, -1 cache only." })),
	}),
	async execute(_toolCallId, params, signal) {
		const contentType = params.contentType ?? "text";
		const maxCharacters = params.maxCharacters ?? 10000;
		const body: Record<string, unknown> = {
			query: params.query,
			type: params.type ?? "auto",
			numResults: params.numResults ?? 5,
		};

		if (params.category) body.category = params.category;
		if (params.includeDomains?.length) body.includeDomains = params.includeDomains;
		if (params.excludeDomains?.length) body.excludeDomains = params.excludeDomains;
		if (typeof params.maxAgeHours === "number") body.maxAgeHours = params.maxAgeHours;
		if (contentType === "text") body.contents = { text: { maxCharacters } };
		if (contentType === "highlights") body.contents = { highlights: { maxCharacters } };

		const data = await exaRequest<ExaSearchResponse>("/search", body, signal);
		const results = data.results ?? [];

		return {
			content: [
				{
					type: "text",
					text: renderSearchResults(results),
				},
			],
			details: {
				query: params.query,
				resultCount: results.length,
				results,
			},
		};
	},
});

const exaGetContentsTool = defineTool({
	name: "exa_get_contents",
	label: "Exa Get Contents",
	description: "Fetch extracted text or highlights for one or more known URLs using Exa.",
	promptGuidelines: [
		"Use this when you already have URLs and want Exa to extract page content.",
		"Prefer highlights when you only need key excerpts. Use text for more contiguous content.",
	],
	parameters: Type.Object({
		urls: Type.Array(Type.String({ description: "A URL to fetch" }), {
			minItems: 1,
			maxItems: 10,
			description: "URLs to fetch contents for",
		}),
		contentType: Type.Optional(StringEnum(["text", "highlights"] as const, { description: "text or highlights. Default text." })),
		maxCharacters: Type.Optional(Type.Number({ minimum: 500, maximum: 50000, description: "Max extracted characters per URL. Default 10000." })),
		query: Type.Optional(Type.String({ description: "Optional relevance query for highlights extraction." })),
		maxAgeHours: Type.Optional(Type.Number({ description: "Freshness threshold in hours. 0 forces livecrawl, -1 cache only." })),
	}),
	async execute(_toolCallId, params, signal) {
		const contentType = params.contentType ?? "text";
		const maxCharacters = params.maxCharacters ?? 10000;
		const body: Record<string, unknown> = {
			urls: params.urls,
		};

		if (typeof params.maxAgeHours === "number") body.maxAgeHours = params.maxAgeHours;
		if (contentType === "text") body.text = { maxCharacters };
		if (contentType === "highlights") {
			body.highlights = params.query
				? { maxCharacters, query: params.query }
				: { maxCharacters };
		}

		const data = await exaRequest<ExaContentsResponse>("/contents", body, signal);
		const results = data.results ?? [];

		return {
			content: [
				{
					type: "text",
					text: renderContentsResults(results),
				},
			],
			details: {
				resultCount: results.length,
				results,
			},
		};
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(exaSearchTool);
	pi.registerTool(exaGetContentsTool);
}
