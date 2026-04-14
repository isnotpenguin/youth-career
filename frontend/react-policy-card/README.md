 ## React Policy Card
 
 - Component: `src/PolicyCard.tsx`
 - Offline cache: `src/policyCardCache.ts` (IndexedDB, falls back to localStorage)
 
 ### Use
 
 ```tsx
 import { PolicyCard } from "./src/PolicyCard";
 
 <PolicyCard
   card={card}
   onToggleSave={async (nextSaved) => {
     // Optional: call your API when online to persist saved state
   }}
 />
 ```
