import type { PolicyCardData } from "./types";

type CacheRecord<T> = { value: T; cachedAtISO: string };

const DB_NAME = "ycpn_cache";
const STORE = "policy_cards";
const DB_VERSION = 1;

function hasIndexedDB(): boolean {
  return typeof indexedDB !== "undefined";
}

async function openDB(): Promise<IDBDatabase> {
  return await new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (!db.objectStoreNames.contains(STORE)) db.createObjectStore(STORE);
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function idbGet<T>(key: string): Promise<T | null> {
  const db = await openDB();
  return await new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readonly");
    const store = tx.objectStore(STORE);
    const req = store.get(key);
    req.onsuccess = () => resolve((req.result as T) ?? null);
    req.onerror = () => reject(req.error);
  });
}

async function idbSet<T>(key: string, value: T): Promise<void> {
  const db = await openDB();
  await new Promise<void>((resolve, reject) => {
    const tx = db.transaction(STORE, "readwrite");
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
    tx.objectStore(STORE).put(value as any, key);
  });
}

function lsKey(id: string) {
  return `policy_card:${id}`;
}

export async function cachePolicyCard(card: PolicyCardData): Promise<void> {
  const record: CacheRecord<PolicyCardData> = { value: card, cachedAtISO: new Date().toISOString() };
  if (hasIndexedDB()) {
    await idbSet(lsKey(card.id), record);
    return;
  }
  localStorage.setItem(lsKey(card.id), JSON.stringify(record));
}

export async function getCachedPolicyCard(id: string): Promise<PolicyCardData | null> {
  const key = lsKey(id);
  if (hasIndexedDB()) {
    const record = await idbGet<CacheRecord<PolicyCardData>>(key);
    return record?.value ?? null;
  }
  const raw = localStorage.getItem(key);
  if (!raw) return null;
  try {
    const record = JSON.parse(raw) as CacheRecord<PolicyCardData>;
    return record.value ?? null;
  } catch {
    return null;
  }
}

