export class ObservedChannelMembers {
  constructor() {
    this.data = []
  }

  // 監視ユーザーのON, OFF
  toggleObserve(channelId, accountId, isOn) {
  }

  // チャンネルの追加
  registerChannel(channelId, accountIds) {
    if (this.#isRegisterd(channelId)) return

    const members = accountIds.map(id => ({ accountId: id, observe: false }))

    this.data.push({channelId: channelId, members: members})
  }

  // チャンネルの削除
  deleteChannel(channel_id) {
  }

  #isRegisterd(channelId) {
    const channelIds = this.#getChannelIds()

    if (channelIds.length === 0) return false

    return channelIds.findIndex(id => id === channelId) !== -1
  }

  #getChannelIds() {
    return this.data.map(d => d.channelId)
  }
}
