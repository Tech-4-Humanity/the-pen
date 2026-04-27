-- ops.predev v1.0 DDL
-- Apply to: Supabase lzfgigiyqpuuxslsygjt, schema: public
-- Idempotent: all CREATE IF NOT EXISTS

CREATE TABLE IF NOT EXISTS public.ops_predev (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  title             text        NOT NULL,
  item_type         text        NOT NULL DEFAULT 'wip'
                                CHECK (item_type IN ('wip','pen')),
  status            text        NOT NULL DEFAULT 'parked'
                                CHECK (status IN ('parked','blocked','ready','promoted','cancelled')),
  priority          int         NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
  pillar            text,
  business_key      text,
  source_type       text        NOT NULL DEFAULT 'manual',
  source_ref        text,
  blocked_by        uuid[]      NOT NULL DEFAULT '{}',
  block_ref         text,
  promote_to        text,
  auto_promote      boolean     NOT NULL DEFAULT false,
  promoted_queue_id uuid,
  notes             text,
  is_rd             boolean     NOT NULL DEFAULT false,
  project_code      text,
  cancelled_reason  text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ops_predev_status_idx      ON public.ops_predev (status);
CREATE INDEX IF NOT EXISTS ops_predev_pillar_idx      ON public.ops_predev (pillar);
CREATE INDEX IF NOT EXISTS ops_predev_business_idx    ON public.ops_predev (business_key);
CREATE INDEX IF NOT EXISTS ops_predev_priority_idx    ON public.ops_predev (priority DESC);
CREATE INDEX IF NOT EXISTS ops_predev_blocked_by_idx  ON public.ops_predev USING GIN (blocked_by);

-- updated_at auto-maintenance
CREATE OR REPLACE FUNCTION public.predev_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;

DROP TRIGGER IF EXISTS predev_updated_at ON public.ops_predev;
CREATE TRIGGER predev_updated_at
  BEFORE UPDATE ON public.ops_predev
  FOR EACH ROW EXECUTE FUNCTION public.predev_set_updated_at();

-- Unblock cascade: when item promoted, remove from dependents' blocked_by
-- If blocked_by becomes empty, auto-advance to ready
CREATE OR REPLACE FUNCTION public.predev_unblock_cascade()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'promoted' AND OLD.status <> 'promoted' THEN
    UPDATE public.ops_predev
      SET blocked_by = array_remove(blocked_by, NEW.id)
      WHERE NEW.id = ANY(blocked_by);
    UPDATE public.ops_predev
      SET status = 'ready'
      WHERE blocked_by = '{}'
        AND status = 'blocked';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS predev_unblock_trigger ON public.ops_predev;
CREATE TRIGGER predev_unblock_trigger
  AFTER UPDATE ON public.ops_predev
  FOR EACH ROW EXECUTE FUNCTION public.predev_unblock_cascade();

-- Ready queue view
CREATE OR REPLACE VIEW public.v_predev_ready AS
  SELECT * FROM public.ops_predev
  WHERE status = 'ready'
  ORDER BY priority ASC, created_at ASC;

-- Blocked items with dependency titles (for UI)
CREATE OR REPLACE VIEW public.v_predev_blocked AS
  SELECT
    p.*,
    (
      SELECT json_agg(json_build_object('id', b.id, 'title', b.title, 'status', b.status))
      FROM public.ops_predev b
      WHERE b.id = ANY(p.blocked_by)
    ) AS blocker_details
  FROM public.ops_predev p
  WHERE p.status = 'blocked'
  ORDER BY p.priority ASC, p.created_at ASC;

COMMENT ON TABLE public.ops_predev IS 'ops.predev v1.0 — pre-development operations. Replaces WIP and The Pen holding concepts.';
