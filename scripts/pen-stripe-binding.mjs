// Stripe binding (log-only by default; requires secrets to send)
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripeKey = process.env.STRIPE_SECRET_KEY;
const sbUrl = process.env.SUPABASE_URL;
const sbKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const stripe = stripeKey ? new Stripe(stripeKey) : null;
const sb = (sbUrl && sbKey) ? createClient(sbUrl, sbKey, { auth: { persistSession: false }}) : null;

if (!sb) {
  console.log('Supabase not configured; skipping');
  process.exit(0);
}

// Pull recent value events that are ready
const { data: events } = await sb
  .from('pen_value_events')
  .select('*')
  .eq('monetisation_status','ready')
  .limit(10);

for (const e of events || []) {
  try {
    if (!stripe) throw new Error('Stripe not configured');

    const invoiceItem = await stripe.invoiceItems.create({
      customer: e.stripe_customer_id,
      currency: e.currency.toLowerCase(),
      unit_amount: e.unit_amount_cents,
      quantity: e.quantity,
      description: `Pen execution: ${e.task_id}`
    });

    await sb.from('pen_value_events').update({
      stripe_invoice_item_id: invoiceItem.id,
      monetisation_status: 'sent_to_stripe'
    }).eq('id', e.id);
  } catch (err) {
    await sb.from('pen_value_events').update({
      monetisation_status: 'failed',
      metadata: { error: String(err) }
    }).eq('id', e.id);
  }
}
