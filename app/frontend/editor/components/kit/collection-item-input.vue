<template>
  <div>
    <label class="block font-semibold text-gray-800" :for="name">
      {{ label }}
    </label>

    <select-input
      :withLabel="false"
      :placeholder="$t(`collectionItemInput.select.placeholder`)"
      :searchEnabled="true"
      :searchPlaceholder="$t(`collectionItemInput.select.searchPlaceholder`)"
      :emptyLabel="$t(`collectionItemInput.select.emptyLabel`)"
      :fetchList="(q) => services.collectionItem.findAll(collectionId, { q })"
      :clearEnabled="true"
      buttonClass="h-10"
      v-model="selectedCollectionItem"
    >
      <template v-slot:value>
        <div class="flex items-center">
          <div
            class="h-10 w-10 bg-gray-400 mr-3"
            v-if="selectedCollectionItem.imageUrl"
          >
            <img
              class="object-cover w-full h-full"
              :src="selectedCollectionItem.imageUrl"
            />
          </div>
          <span>{{ selectedCollectionItem.label }}</span>
        </div>
      </template>
      <template v-slot:item="{ item }">
        <div class="flex items-center">
          <div class="h-10 w-10 bg-gray-400 mr-3" v-if="item.imageUrl">
            <img class="object-cover w-full h-full" :src="item.imageUrl" />
          </div>
          <span class="font-bold">{{ item.label }}</span>
        </div>
      </template>
    </select-input>
  </div>
</template>

<script>
import { camelizeKeys } from '@/misc/utils'

export default {
  name: 'CollectionItemInput',
  props: {
    label: { type: String, default: 'Label' },
    name: { type: String, default: 'image' },
    value: { default: () => null },
    collectionId: { type: String },
    isFocused: { type: Boolean, default: false },
  },
  computed: {
    selectedCollectionItem: {
      get() {
        return camelizeKeys(this.value)
      },
      set(collectionItem) {
        this.$emit('input', collectionItem ? { ...collectionItem } : null)
      },
    },
  },
}
</script>
