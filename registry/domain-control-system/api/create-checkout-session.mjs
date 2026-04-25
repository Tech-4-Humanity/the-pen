import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default async function handler(req, res) {
  try {
    const { sku } = req.body || {};
    const priceMap = {
      dcs_audit_once: process.env.STRIPE_PRICE_AUDIT,
      dcs_cleanup_pack: process.env.STRIPE_PRICE_CLEANUP,
      dcs_monitor_monthly: process.env.STRIPE_PRICE_MONITOR,
      dcs_enterprise_monthly: process.env.STRIPE_PRICE_ENTERPRISE
    };

    const price = priceMap[sku];
    if (!price) return res.status(400).json({ error: 'invalid sku' });

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: sku.includes('monthly') ? 'subscription' : 'payment',
      line_items: [{ price, quantity: 1 }],
      success_url: `${req.headers.origin}/success`,
      cancel_url: `${req.headers.origin}/cancel`,
      metadata: { sku }
    });

    res.status(200).json({ url: session.url });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
