import { JSONExtensionUpdated } from "../generated/JSONExtensionRegistry/JSONExtensionRegistry";
import { ContractExtensionData } from "../generated/schema";
import { loadMetadataInfoFromID } from "./helpers/load-metadata-info-from-id";
import { getIPFSHostFromURI } from "./helpers/get-ipfs-host-from-uri";

export function handleJSONExtensionUpdated(event: JSONExtensionUpdated): void {
  const extensionData = new ContractExtensionData(event.params.target);
  extensionData.url = event.params.newValue;
  extensionData.updater = event.params.updater;
  extensionData.origin = event.transaction.from;
  extensionData.updatedAt = event.block.timestamp;
  extensionData.updatedTx = event.transaction.hash;
  extensionData.metadata = loadMetadataInfoFromID(
    getIPFSHostFromURI(event.params.newValue)
  );

  extensionData.save();
}
