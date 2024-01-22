import { MetadataInfo as MetadataInfoTemplate } from "../../generated/templates";

export function loadMetadataInfoFromID(id: string | null): string | null {
  if (id !== null) {
    MetadataInfoTemplate.create(id);
  }

  return id;
}
