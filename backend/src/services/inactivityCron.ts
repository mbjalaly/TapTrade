// @ts-ignore - node-cron doesn't have type declarations
import cron from 'node-cron';
import supabase from './supabaseClient';

const INACTIVITY_DAYS = 14;

async function deactivateInactiveProducts(): Promise<void> {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - INACTIVITY_DAYS);
  const cutoffISO = cutoff.toISOString();

  console.log(`[InactivityCron] Running check — cutoff date: ${cutoffISO}`);

  // Step 1: Get all users who own at least one active product
  const { data: activeProducts, error: prodErr } = await supabase
    .from('products')
    .select('user_id')
    .eq('status', 'active');

  if (prodErr) {
    console.error('[InactivityCron] Error fetching active products:', prodErr.message);
    return;
  }

  const userIds = [...new Set((activeProducts ?? []).map((p: any) => p.user_id))];
  if (userIds.length === 0) {
    console.log('[InactivityCron] No users with active products — nothing to do.');
    return;
  }

  // Step 2: For each user, find their last swipe timestamp
  const { data: lastSwipes, error: swipeErr } = await supabase
    .from('match_feedback')
    .select('user_id, created_at')
    .in('user_id', userIds)
    .order('created_at', { ascending: false });

  if (swipeErr) {
    console.error('[InactivityCron] Error fetching swipe data:', swipeErr.message);
    return;
  }

  // Build map of user_id → most recent swipe
  const lastSwipeMap = new Map<string, string>();
  for (const row of lastSwipes ?? []) {
    if (!lastSwipeMap.has(row.user_id)) {
      lastSwipeMap.set(row.user_id, row.created_at);
    }
  }

  // Step 3: Determine inactive users (last swipe > 14 days ago, or never swiped)
  const inactiveUserIds = userIds.filter((uid) => {
    const lastSwipe = lastSwipeMap.get(uid as string);
    if (!lastSwipe) return true; // never swiped
    return new Date(lastSwipe) < cutoff;
  });

  if (inactiveUserIds.length === 0) {
    console.log('[InactivityCron] All users with active products are still active.');
    return;
  }

  // Step 4: Deactivate all products for inactive users
  const { data: updated, error: updateErr } = await supabase
    .from('products')
    .update({ status: 'inactive' })
    .eq('status', 'active')
    .in('user_id', inactiveUserIds)
    .select('id');

  if (updateErr) {
    console.error('[InactivityCron] Error deactivating products:', updateErr.message);
    return;
  }

  const count = updated?.length ?? 0;
  console.log(`[InactivityCron] Deactivated ${count} product(s) for ${inactiveUserIds.length} inactive user(s).`);
}

export function startInactivityCron(): void {
  // Run daily at 03:00 UTC
  cron.schedule('0 3 * * *', () => {
    deactivateInactiveProducts().catch((err) => {
      console.error('[InactivityCron] Unexpected error:', err);
    });
  });

  console.log('[InactivityCron] Scheduled daily at 03:00 UTC');
}
