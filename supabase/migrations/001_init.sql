-- Portfolio chatbot RAG + leads schema
-- Project: pknpudvmtyfaiunamahm (Chatbot Lab / website-chatbot)
-- Embedding model: gemini-embedding-2 via n8n Embeddings Google Gemini node.
-- That node currently ignores outputDimensionality and emits 3072-d vectors,
-- so the pgvector column is vector(3072) to match live ingest/retrieve.

create extension if not exists vector;

-- RAG vector store (n8n Supabase Vector Store / LangChain)
create table if not exists public.documents (
  id bigserial primary key,
  content text,
  metadata jsonb,
  embedding vector(3072)
);

create or replace function public.match_documents (
  query_embedding vector(3072),
  match_count int default null,
  filter jsonb default '{}'
)
returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
language plpgsql
as $$
#variable_conflict use_column
begin
  return query
  select
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from public.documents
  where metadata @> filter
  order by documents.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- Lead capture (n8n Supabase insert node)
create table if not exists public.leads (
  id bigserial primary key,
  name text not null,
  email text not null,
  message text,
  session_id text,
  created_at timestamptz not null default now(),
  constraint leads_email_format check (
    email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
  ),
  constraint leads_session_email_unique unique (session_id, email)
);

-- PII / RAG content: deny anon; n8n uses service_role (bypasses RLS)
alter table public.documents enable row level security;
alter table public.leads enable row level security;

revoke all on table public.documents from anon, authenticated;
revoke all on table public.leads from anon, authenticated;
revoke all on function public.match_documents(vector, int, jsonb) from anon, authenticated;

grant usage on schema public to anon, authenticated, service_role;
grant all on table public.documents to service_role;
grant all on table public.leads to service_role;
grant all on sequence public.documents_id_seq to service_role;
grant all on sequence public.leads_id_seq to service_role;
grant execute on function public.match_documents(vector, int, jsonb) to service_role;
